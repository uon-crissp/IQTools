using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading;
using DataLayer;
using GsmComm.GsmCommunication;
using GsmComm.PduConverter;
using System.Management;


namespace IQToolsWindowsService
{
    public partial class Service1 : ServiceBase
    {
        System.Threading.Timer oTimer;
        System.Threading.Timer oTimer2;
        DataTable oSMSSchedules =  new DataTable();
        string SQLQuery;
        DataLayer.Entity theObject = new DataLayer.Entity();
        GsmCommMain comm;
        private const int MSG_SENT = 1;
        private const int MSG_FAILED = 2;
        private const int MSG_RECEIVED = 3;
        private static string xmlPath = "C:\\Cohort\\Service.config";
        Thread SendSMSThread;

        string FacilityName = "";
        string EMR = "";
        string EMRVersion = "";
        string ServerType = Entity.getServerType(xmlPath);

        public Service1()
        {
            InitializeComponent();
        }

        public void OnDebug()
        {
            OnStart(null);
        }

        protected override void OnStart(string[] args)
        {
            SetRefreshVariables();
            RunDynamicRefresh();
            RunSMSTasks();
        }

        protected override void OnStop()
        {
            WriteToEventLogs("IQTools Service Stopped",EventLogEntryType.Information);
        }

        public void RunSMSTasks()
        {
            ConnectModem();
            LoadSMSSchedules();

            const Int32 iTIME_INTERVAL = 60000; //60 seconds
            TimerCallback timerDelegate = new TimerCallback(SendDueSMS);
            oTimer2 = new System.Threading.Timer(timerDelegate, null, 0, iTIME_INTERVAL);
        }

        private void ConnectModem()
        {
            try
            {
                int port = 3;
                int baudrate = 19200;
                int timeout = 2000;

                ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_POTSModem");
                foreach (ManagementObject modem in searcher.Get())
                {
                    port = (int)Convert.ToSingle(modem.GetPropertyValue("AttachedTo").ToString().Substring(3)); ;
                }

                comm = new GsmCommMain(port, baudrate, timeout);
                comm.Open();

                WriteToEventLogs("Modem connected successfully", EventLogEntryType.Information);
            }
            catch(Exception ex)
            {
                WriteToEventLogs("Error while connecting Modem: " + ex.Message, EventLogEntryType.Error);
            }
        }

        public void LoadSMSSchedules()
        {
            try
            {
                DataLayer.ClsUtility.Init_Hashtable();

                SQLQuery = "SELECT a.ScheduleID , a.ScheduleName , a.QryID , a.SendUsing , a.SendUsingDetails ," +
                            " a.DailyDaysEarlier , a.ScheduleType , a.DailyTime , a.WeeklyDay , a.WeeklyTime ," +
                            " a.MonthlyDay , a.MonthlyTime , a.CreateDate , a.UpdateDate ," +
                            " (SELECT DISTINCT b.[Message]+' / ' FROM dbo.aa_SMS b WHERE b.QryID = a.QryID AND " +
                            " ISNULL(b.Deleteflag, 0)=0 FOR XML PATH('')) AS [Message], b.qryDefinition" +
                            " FROM dbo.aa_SMSSchedules a" +
                            " INNER JOIN dbo.aa_Queries b ON a.QryID = b.qryID";

                oSMSSchedules = (DataTable)theObject.ReturnObject(DataLayer.Entity.getconnString(xmlPath)
                                , DataLayer.ClsUtility.theParams, SQLQuery, DataLayer.ClsUtility.ObjectEnum.DataTable, ServerType);

                WriteToEventLogs("SMS Schedules loaded successfully", EventLogEntryType.Information);
            }
            catch (Exception ex)
            {
                WriteToEventLogs("Error while loading SMS schedules: " + ex.Message, EventLogEntryType.Error);
            }
        }

        public void SendDueSMS(object o)
        {
            DateTime StartDate = DateTime.Now.Date;
            DateTime EndDate = DateTime.Now.Date;
            string Message;
            DataTable dt = new DataTable();
            string sCountryCode = "+254";
            bool ScheduleIsDue = false;
            string CurrentTime = DateTime.Now.ToString("hh:mm");
            string sFrequency = string.Empty;

            try
            {
                for (int i = oSMSSchedules.Rows.Count - 1; i >= 0; i--)
                {
                    ScheduleIsDue = false;
                    sFrequency = oSMSSchedules.Rows[i]["ScheduleType"].ToString();

                    //Get the query start date and end date based on the type of schedule
                    if (sFrequency == "Daily")
                    {
                        if (Convert.ToDateTime(oSMSSchedules.Rows[i]["DailyTime"]).ToString("hh:mm") == CurrentTime)
                        {
                            StartDate = DateTime.Now.Date.AddDays(Convert.ToDouble(oSMSSchedules.Rows[i]["DailyDaysEarlier"]));
                            EndDate = DateTime.Now.Date.AddDays(Convert.ToDouble(oSMSSchedules.Rows[i]["DailyDaysEarlier"]));
                            ScheduleIsDue = true;
                        }
                    }
                    else if (sFrequency == "Weekly")
                    {
                        if (Convert.ToDateTime(oSMSSchedules.Rows[i]["WeeklyTime"]).ToString("hh:mm") == CurrentTime
                            && DateTime.Now.DayOfWeek.ToString() == oSMSSchedules.Rows[i]["WeeklyDay"].ToString())
                        {
                            StartDate = DateTime.Now.Date.AddDays(Convert.ToDouble(oSMSSchedules.Rows[i]["DailyDaysEarlier"]));
                            EndDate = StartDate.AddDays(7);
                            ScheduleIsDue = true;
                        }
                    }
                    else if (sFrequency == "Monthly")
                    {
                        if (Convert.ToDateTime(oSMSSchedules.Rows[i]["MonthlyTime"]).ToString("hh:mm") == CurrentTime
                            && DateTime.Now.Day.ToString() == oSMSSchedules.Rows[i]["MonthlyDay"].ToString())
                        {
                            StartDate = DateTime.Now.Date.AddDays(Convert.ToDouble(oSMSSchedules.Rows[i]["DailyDaysEarlier"]));
                            EndDate = StartDate.AddDays(30);
                            ScheduleIsDue = true;
                        }
                    }

                    if (ScheduleIsDue)
                    {
                        //Send SMS using Modem or web service
                        SQLQuery = oSMSSchedules.Rows[i]["qryDefinition"].ToString();
                        Message = oSMSSchedules.Rows[i]["Message"].ToString();

                        if (oSMSSchedules.Rows[i]["SendUsing"].ToString().ToLower() == "modem")
                        {
                            SendSMSThread = new Thread(() => SendMsgUsingModem(Message, sCountryCode, SQLQuery, StartDate, EndDate, sFrequency));
                            SendSMSThread.SetApartmentState(ApartmentState.STA);
                            try
                            {
                                SendSMSThread.Start();
                            }
                            catch (Exception ex)
                            {
                                WriteToEventLogs("Error on SendDueSMS: " + ex.Message, EventLogEntryType.Error);
                            }
                        }
                        else
                        {
                            SendSMSThread = new Thread(() => SendMsgUsingWebServ(Message, sCountryCode, SQLQuery, StartDate, EndDate, sFrequency));
                            SendSMSThread.SetApartmentState(ApartmentState.STA);
                            try
                            {
                                SendSMSThread.Start();
                            }
                            catch (Exception ex)
                            {
                                WriteToEventLogs("Error on SendDueSMS: " + ex.Message, EventLogEntryType.Error);
                            }
                        }

                        //Remove item from list, as this schedule will now run automatically in a thread
                        oSMSSchedules.Rows[i].Delete();
                    }
                }
            }
            catch (Exception ex)
            {
                WriteToEventLogs("Error on SendDueSMS: " + ex.Message, EventLogEntryType.Error);
            }
        }

        private void SendMsgUsingModem(string SMSText, string countryCode, string SQLQuery, DateTime QryStartDate, DateTime QryEndDate, string Frequency)
        {
            string PatientPK = "";
            DataTable contacts;
            string sSQL_1 = string.Empty;
            int ThreadSleepTime = 0;
            string msg = string.Empty;

            //Check if modem is connected
            if (!comm.IsConnected())
            {
                ConnectModem();
            }

            for (; ; ) //Loop indefinately
            {
                sSQL_1 = SQLQuery.Replace("@startdate", QryStartDate.ToString());
                sSQL_1 = sSQL_1.Replace("@enddate", QryEndDate.ToString());

                //Run the query to load phone numbers
                contacts = new DataTable();

                contacts = (DataTable)theObject.ReturnObject(DataLayer.Entity.getconnString(xmlPath),
                                DataLayer.ClsUtility.theParams, sSQL_1, DataLayer.ClsUtility.ObjectEnum.DataTable, ServerType);

                try
                {
                    foreach (DataRow dr in contacts.Rows)
                    {
                        try
                        {
                            if (dr["Phone"] != null)
                            {
                                string pNum;
                                if (dr["Phone"].ToString().Substring(0, 1) == "0" && countryCode.Length > 1)
                                {
                                    pNum = countryCode.Trim() + dr["Phone"].ToString().Substring(1);
                                }
                                else if (dr["Phone"].ToString().Substring(0, 1) == "+")
                                {
                                    pNum = dr["Phone"].ToString();
                                }
                                else
                                {
                                    pNum = "";
                                }

                                if (pNum != "")
                                {
                                    msg = SMSText.Replace("XX-XX-XXXX", dr["NextAppointmentDate"].ToString());
                                    PatientPK = dr["PatientPK"].ToString();

                                    try
                                    {
                                        SmsSubmitPdu pdu = new SmsSubmitPdu(msg, pNum, "");
                                        comm.SendMessage(pdu);
                                        LogMessage(PatientPK, pNum, msg, MSG_SENT);
                                    }
                                    catch
                                    {
                                        LogMessage(PatientPK, pNum, msg, MSG_FAILED);
                                    }
                                }
                                else break;
                            }
                        }
                        catch(Exception ex)
                        {
                            WriteToEventLogs("Error while sending SMS - " + ex.Message, EventLogEntryType.Error);
                        }
                    }
                }
                catch (Exception ex)
                {
                    WriteToEventLogs("Error while sending SMS - " + ex.Message, EventLogEntryType.Error);
                }

                //Set parameters for the next run
                if (Frequency.ToLower() == "monthly")
                {
                    QryStartDate = QryStartDate.AddDays(1);
                    QryEndDate = QryStartDate;
                    ThreadSleepTime = 24 * 60 * 60 * 1000; //24hours
                }
                else if (Frequency.ToLower() == "weekly")
                {
                    QryStartDate = QryStartDate.AddDays(7);
                    QryEndDate = QryEndDate.AddDays(7);
                    ThreadSleepTime = 7 * 24 * 60 * 60 * 1000; //1 Week
                }
                else if (Frequency.ToLower() == "monthly")
                {
                    QryStartDate = QryStartDate.AddMonths(1);
                    QryEndDate = QryEndDate.AddMonths(1);
                    ThreadSleepTime = DateTime.DaysInMonth(DateTime.Now.Year, DateTime.Now.Month) * 24 * 60 * 60 * 1000; //1 Month
                }
                
                //Sleep for a time interval
                Thread.Sleep(ThreadSleepTime);
            }
        }

        private void SendMsgUsingWebServ(string SMSText, string countryCode, string SQLQuery, DateTime QryStartDate, DateTime QryEndDate, string Frequency)
        {
            //td
        }

        private void LogMessage(string PatientPK, string Phone, string Msg, int MsgStatus)
        {
            ClsUtility.Init_Hashtable();
            string sSQl = string.Empty;
            string CurrentDate = DateTime.Now.ToShortDateString();

            if (MsgStatus == MSG_SENT)
            {
                sSQl = "INSERT INTO aa_SMSLogs ( PatientPK , Phone , Message , MsgSent , MsgFailed , MsgReceived , LogDate , UserID)" +
                          "VALUES('" + PatientPK + "', '" + Phone + "', '" + Msg + "','1','0','0'," + CurrentDate + ",'0')";
            }
            else if (MsgStatus == MSG_FAILED)
            {
                sSQl = "INSERT INTO aa_SMSLogs ( PatientPK , Phone , Message , MsgSent , MsgFailed , MsgReceived , LogDate , UserID)" +
                          "VALUES('" + PatientPK + "', '" + Phone + "', '" + Msg + "','0','1','0'," + CurrentDate + ",'0')";
            }
            else if (MsgStatus == MSG_RECEIVED)
            {
                sSQl = "INSERT INTO aa_SMSLogs ( PatientPK , Phone , Message , MsgSent , MsgFailed , MsgReceived , LogDate , UserID)" +
                          "VALUES('" + PatientPK + "', '" + Phone + "', '" + Msg + "','0','0','1'," + CurrentDate + ",'0')";
            }

            //Log SMS
            try
            {
                theObject.ReturnObject(Entity.getconnString(xmlPath), ClsUtility.theParams, sSQl, ClsUtility.ObjectEnum.ExecuteNonQuery, ServerType);
            }
            catch (Exception ex)
            {
                WriteToEventLogs("Error while logging SMS: " + ex.Message, EventLogEntryType.Error);
            }
        }

        private void RunDynamicRefresh()
        {
            const Int32 iTIME_INTERVAL = 60000;           
            TimerCallback timerDelegate = new TimerCallback(RefreshIQTools);
            oTimer = new System.Threading.Timer(timerDelegate, null, 0, iTIME_INTERVAL);
        }

        private void RefreshIQTools(object o)
        {
            ClsUtility.Init_Hashtable();
            try
            {
                ClsUtility.AddParameters("@EMR", SqlDbType.Text, EMR);
                ClsUtility.AddParameters("@EMRVersion", SqlDbType.Text, EMRVersion);
                ClsUtility.AddParameters("@FacilityName", SqlDbType.Text, FacilityName);
                int i = (int)theObject.ReturnObject(Entity.getconnString(xmlPath), ClsUtility.theParams
                                                    , "pr_DynamicRefresh_IQTools", ClsUtility.ObjectEnum.ExecuteNonQuery, ServerType);
            }
            catch (Exception ex)
            {
                WriteToEventLogs("Error while refreshing IQTools: " + ex.Message, EventLogEntryType.Error);
            }
            finally { ClsUtility.Init_Hashtable(); };
        }

        private void SetRefreshVariables()
        {
            try
            {
                ClsUtility.Init_Hashtable();
                string SQL = "Select b.FacilityName " +
                            ", a.PMMS EMR " +
                            ", a.EMRVersion " +
                            "FROM aa_Database a, (Select FacilityName FROM IQC_SiteDetails WHERE FacilityID IN ( " +
                            "Select Min(FacilityID) mf FROM IQC_SiteDetails))b";
                DataRow dr = (DataRow)theObject.ReturnObject(Entity.getconnString(xmlPath), ClsUtility.theParams
                    , SQL, ClsUtility.ObjectEnum.DataRow, ServerType);

                FacilityName = dr["FacilityName"].ToString();
                EMR = dr["EMR"].ToString();
                EMRVersion = dr["EMRVersion"].ToString();

                WriteToEventLogs("Refresh variables set succesfully", EventLogEntryType.Information);
            }
            catch (Exception ex)
            {
                WriteToEventLogs("Error while setting refresh variables: " + ex.Message, EventLogEntryType.Error);
            }
        }

        private void WriteToEventLogs(string LogMessage, EventLogEntryType EntryType)
        {
            EventLog m_EventLog = new EventLog();
            m_EventLog.Source = "IQTools Service";
            m_EventLog.WriteEntry(LogMessage, EntryType);
        }

    }
}
