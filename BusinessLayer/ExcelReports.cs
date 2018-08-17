//using System;
//using DataLayer;
//using System.Data;
//using System.Collections;
//using System.Data.SqlClient;
//using System.IO;
//using System.Windows.Forms;
//using System.Threading;
//using Excel = Microsoft.Office.Interop.Excel;
//using System.Xml;
//using System.Net;
//using System.Text;
//using MySql.Data.MySqlClient;
//using System.Collections.Generic;
//using System.Runtime.InteropServices;
using OfficeOpenXml;
using OfficeOpenXml.Table;
using System;
using System.Data;
using System.IO;
using System.Linq;

namespace BusinessLayer
{
  public class ExcelReports
  {

        //  Entity theObject; Hashtable myParameters;
        //  string xlTemplate = ""; string xlFileName = ""; string xlWorkSheet = "";
        //  private object m_objOpt = System.Reflection.Missing.Value;
        //  Excel.Application oExcel; Excel.Workbook oBook; Excel.Worksheet oWs; Excel.Worksheet tWs;
        //  public String DHIS2Credentials = ":";
        //  public DateTime EndDateDHIS, StartDateDHIS;
        //  public string MFLCode, DHISCode, DHIS2URL;
        //  public bool bPatSummaryBulkReport = false; //KKirui - Bulk patient summary reports
        //  string serverType = Entity.getServerType(clsGbl.xmlPath);

        //  #region Reports

        //  public void AIDSRelief ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "HIV Care And Treatment Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "HIV Monthly Report\\HIV Care And Treatment Monthly Report - " + getRptEnd(pmARQueries).Year + " " + getRptEnd(pmARQueries).Month + " " + getRptEnd(pmARQueries).Day + " - " + getLPTF() + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'AIDSRelief'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    //getQueries(Convert.ToInt32(theDr["CatID"].ToString()), locType, dbSet, cccSet, locTable, false, null);
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, false, pb );

        //  }

        //  public void MoH361B ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "MoH361B Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "NASCOP Report\\MoH361B Monthly Report - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'MoH361B'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void MoH717(Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb)
        //  {
        //      DataRow theDr;
        //      xlWorkSheet = "LPTF";
        //      theObject = new Entity();
        //      myParameters = pmARQueries;
        //      xlTemplate = clsGbl.tmpFolder + "MOH 717 Template.xls";
        //      xlFileName = clsGbl.tmpFolder + "NASCOP Report\\MOH 717 Monthly Report - " + getRptEnd(pmARQueries).Year + " " + getRptEnd(pmARQueries).Month + " " + getRptEnd(pmARQueries).Day + " - " + getLPTF() + ".xls";
        //      theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'MOH 717'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType);
        //      int catID = Convert.ToInt32(theDr["CatID"].ToString());
        //      runReport(catID, locType, dbSet, cccSet, locTable, bySheet, pb);
        //  }  //LOmare -- MoH 717 OutPatient Data

        //  public void MoH705A(Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb)
        //  {
        //      DataRow theDr;
        //      xlWorkSheet = "LPTF";
        //      theObject = new Entity();
        //      myParameters = pmARQueries;
        //      xlTemplate = clsGbl.tmpFolder + "MOH 705A Template.xls";
        //      xlFileName = clsGbl.tmpFolder + "NASCOP Report\\MOH 705A Monthly Report - " + getRptEnd(pmARQueries).Year + " " + getRptEnd(pmARQueries).Month + " " + getRptEnd(pmARQueries).Day + " - " + getLPTF() + ".xls";
        //      theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'MOH 705A'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType);
        //      int catID = Convert.ToInt32(theDr["CatID"].ToString());
        //      runReport(catID, locType, dbSet, cccSet, locTable, bySheet, pb);
        //  }  //LOmare -- MoH 705A OutPatient Morbidity <5


        //  public void MoH705B(Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb)
        //  {
        //      DataRow theDr;
        //      xlWorkSheet = "LPTF";
        //      theObject = new Entity();
        //      myParameters = pmARQueries;
        //      xlTemplate = clsGbl.tmpFolder + "MOH 705B Template.xls";
        //      xlFileName = clsGbl.tmpFolder + "NASCOP Report\\MOH 705B Monthly Report - " + getRptEnd(pmARQueries).Year + " " + getRptEnd(pmARQueries).Month + " " + getRptEnd(pmARQueries).Day + " - " + getLPTF() + ".xls";
        //      theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'MOH 705B'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType);
        //      int catID = Convert.ToInt32(theDr["CatID"].ToString());
        //      runReport(catID, locType, dbSet, cccSet, locTable, bySheet, pb);
        //  }  //LOmare -- MoH 705B OutPatient Morbidity >5

        //  public void OIDrugsReport(Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb)
        //  {
        //      DataRow theDr;
        //      xlWorkSheet = "LPTF";
        //      theObject = new Entity();
        //      myParameters = pmARQueries;
        //      xlTemplate = Application.StartupPath + "\\Templates\\OI Drugs Report Template.xls";
        //      xlFileName = clsGbl.tmpFolder + "SCM Report\\OI Drugs Report - " + getRptEnd(pmARQueries).Year + " " + getRptEnd(pmARQueries).Month + " " + getRptEnd(pmARQueries).Day + " - " + getLPTF() + ".xls";
        //      theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'OIDrugsReport'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType);
        //      int catID = Convert.ToInt32(theDr["CatID"].ToString());
        //      runReport(catID, locType, dbSet, cccSet, locTable, bySheet, pb);
        //  }

        //  public void HEIRegister(Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb)
        //  {
        //      DataRow theDr;
        //      xlWorkSheet = "LPTF";
        //      theObject = new Entity();
        //      myParameters = pmARQueries;
        //      xlTemplate = Application.StartupPath + "\\Templates\\HEI Register Template.xls";
        //      xlFileName = clsGbl.tmpFolder + "NASCOP Report\\HEI Register - " + getRptEnd(pmARQueries).Year + " " + getRptEnd(pmARQueries).Month + " " + getRptEnd(pmARQueries).Day + " - " + getLPTF() + ".xls";
        //      theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'HEIRegister'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType);
        //      int catID = Convert.ToInt32(theDr["CatID"].ToString());
        //      runReport(catID, locType, dbSet, cccSet, locTable, bySheet, pb);
        //  }

        //  public void TBSummary ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "TB Summary";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "TB Summary Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "TB Summary\\TB Summary - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'TB Summary'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, false, pb );
        //  }

        //  public void PatientSummary ( Hashtable pmARQueries, double age, string patientID, ProgressBar pb )//string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb)
        //  {
        //    DataRow theDr = null;
        //    xlWorkSheet = "PatientSummary";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    if (age >= 15)
        //    {
        //      xlTemplate = clsGbl.tmpFolder + "PatientSummary_Adult Template.xls";
        //      theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'AdultPatientSummary'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    }
        //    else
        //    {
        //      xlTemplate = clsGbl.tmpFolder + "PatientSummary_Paed Template.xls";
        //      theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'PaedPatientSummary'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    }

        //    xlFileName = clsGbl.tmpFolder + "Patient Summary\\Patient Summary - " + patientID + ".xls";

        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, "all", null, null, null, false, pb );

        //  }

        //  public void CDRR ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "Facilities CDRR";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "Facilities CDRR Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "SCM Report\\Facilities CDRR Monthly Report - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'CDRR'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );

        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, false, pb );

        //  }

        //  public void FMAPS ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    //xlWorkSheet = "ARV Patient Summary";
        //    xlWorkSheet = "MAPS";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "FMAPS Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "SCM Report\\F-MAPS Report - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'F-MAPs'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );

        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, false, pb );

        //  }

        //  public void MCHC ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "MCHC Quarterly Report";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "MCHC Quarterly Report Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "MCHC Report\\MCHC Quarterly Report - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'MCHC Quarterly'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );

        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, false, pb );
        //  }

        //  public void HEICA ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "HCA";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "HCA Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "MCHC Report\\HCA Report - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'HCA'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );

        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, false, pb );
        //  }

        //  public void TzCSR ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {

        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "CSR Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "CSR Report\\CSR Quarterly Report - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'Tz_CSR'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, false, pb );
        //  }

        //  public void TzAPR ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {

        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "APR Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "CSR Report\\APR_SAPR Report - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xlsx";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'Tz_APR'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, false, pb );
        //  }

        //  public void MoH711 ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar prB )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "MoH711";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "MoH711.xls";
        //    xlFileName = clsGbl.tmpFolder + "NASCOP Report\\NASCOP Monthly Report - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";

        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'MoH711'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );



        //    //TODO CHRIS DONE Test Report Generation Threading Move to runReport()

        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, prB );

        //    //Thread runReport = new Thread(() => getQueries(Convert.ToInt32(theDr["CatID"].ToString()), locType, dbSet, cccSet, locTable, bySheet));
        //    //runReport.SetApartmentState(ApartmentState.STA);
        //    //runReport.Start();
        //    //runReport(catID, locType, dbSet, cccSet, locTable, bySheet, prB);

        //    //getQueries(Convert.ToInt32(theDr["CatID"].ToString()), locType, dbSet, cccSet, locTable, bySheet);
        //  }

        //  public void PwP ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "PwP Report Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "PwP Report\\PwP - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'PwP'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void ARTCohort ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "CohortSummaryTable";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "Cohort Analysis Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "ART Cohort Report\\Cohort Analysis Report - " + getRptEnd(pmARQueries).Year + " " + getRptEnd(pmARQueries).Month + " " + getRptEnd(pmARQueries).Day + " - " + getLPTF() + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'ARTCohort'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void DTR ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "Defaulter Tracing Report Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "DTR\\DTR - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'DTR'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void MoH731 ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "MoH731";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "MoH731 Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "NASCOP Report\\MoH731 Monthly Report - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'MoH731'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    //getQueries(Convert.ToInt32(theDr["CatID"].ToString()), locType, dbSet, cccSet, locTable, bySheet,null);
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void KeRC ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "KeRC Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "Report Card\\Report Card - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'KeRC'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    //getQueries(Convert.ToInt32(theDr["CatID"].ToString()), locType, dbSet, cccSet, locTable, bySheet,pb);

        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );

        //  }

        //  public void UCR ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "UCR";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "UCR Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "UCR Report\\UCR Monthly Report - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'UCReport'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    //getQueries(Convert.ToInt32(theDr["CatID"].ToString()), locType, dbSet, cccSet, locTable, bySheet,null);
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void UMoH ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "UMoH Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "UMoH Report\\UmoH Quarterly Report - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'UMOH'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    //getQueries(Convert.ToInt32(theDr["CatID"].ToString()), locType, dbSet, cccSet, locTable, bySheet,null);
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void ARTStart_IQChart ( Hashtable pmASQueries, String oParams )
        //  {
        //    DataRow theDr;
        //    clsGbl.IQDirection = "ARTStart_IQChart";
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmASQueries;
        //    xlTemplate = clsGbl.tmpFolder + "ARTStart Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "ARTStart Report\\ART Report - " + getRptEnd ( pmASQueries ).Year + " " + getRptEnd ( pmASQueries ).Month + " " + getRptEnd ( pmASQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'ARTStart'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    getQueries ( Convert.ToInt32 ( theDr["CatID"].ToString ( ) ), oParams );
        //    clsGbl.IQDirection = "main";
        //  }

        //  public void ARTStart_IQCare ( Hashtable pmASQueries )
        //  {
        //    DataRow theDr;
        //    clsGbl.IQDirection = "ARTStart_IQCare";
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmASQueries;
        //    xlTemplate = clsGbl.tmpFolder + "ARTStart Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "ARTStart Report\\ART Report - " + getRptEnd ( pmASQueries ).Year + " " + getRptEnd ( pmASQueries ).Month + " " + getRptEnd ( pmASQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'ARTStart'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    getQueries ( Convert.ToInt32 ( theDr["CatID"].ToString ( ) ) );
        //    clsGbl.IQDirection = "main";
        //  }

        //  public void CDCReport ( Hashtable pmCDCQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmCDCQueries;
        //    xlTemplate = clsGbl.tmpFolder + "CDC Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "Quarterly Report\\CDC Quarterly Report - " + getRptEnd ( pmCDCQueries ).Year + " " + getRptEnd ( pmCDCQueries ).Month + " " + getRptEnd ( pmCDCQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'CDC Track1.0'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    //getQueries(Convert.ToInt32(theDr["CatID"].ToString()), locType, dbSet, cccSet, locTable, bySheet, pb);
        //    //   getQueries(Convert.ToInt32(theDr["CatID"].ToString()));
        //    //theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'MoH711'", ClsUtility.ObjectEnum.DataRow, "mssql");

        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );


        //  }

        //  public void CDCReport_Nigeria ( Hashtable pmCDCQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmCDCQueries;
        //    xlTemplate = clsGbl.tmpFolder + "CDC Template Nigeria.xls";
        //    xlFileName = clsGbl.tmpFolder + "Quarterly Report\\CDC Quarterly Report Nigeria - " + getRptEnd ( pmCDCQueries ).Year + " " + getRptEnd ( pmCDCQueries ).Month + " " + getRptEnd ( pmCDCQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'CDC Track 1.0-Nigeria'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    //getQueries(Convert.ToInt32(theDr["CatID"].ToString()), locType, dbSet, cccSet, locTable, bySheet,null);

        //    //   getQueries(Convert.ToInt32(theDr["CatID"].ToString()));
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void CDCReport_Tanzania ( Hashtable pmCDCQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmCDCQueries;
        //    xlTemplate = clsGbl.tmpFolder + "CDC Template Tanzania.xls";
        //    xlFileName = clsGbl.tmpFolder + "Quarterly Report\\CDC Quarterly Report Tanzania - " + getRptEnd ( pmCDCQueries ).Year + " " + getRptEnd ( pmCDCQueries ).Month + " " + getRptEnd ( pmCDCQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'CDC Track 1.0-Tanzania'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    //getQueries(Convert.ToInt32(theDr["CatID"].ToString()), locType, dbSet, cccSet, locTable, bySheet,null);

        //    //   getQueries(Convert.ToInt32(theDr["CatID"].ToString()));
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void MonthlyReport_Haiti ( Hashtable pmCDCQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "Formulaire ARV";
        //    theObject = new Entity ( );
        //    myParameters = pmCDCQueries;
        //    xlTemplate = clsGbl.tmpFolder + "Monthly Report Haiti Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "Monthly Report Haiti\\Monthly Report - " 
        //        + getRptEnd ( pmCDCQueries ).Year + " " + getRptEnd ( pmCDCQueries ).Month + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams
        //        , "SELECT CatID FROM aa_Category WHERE Category = 'Haiti_MSPP_Monthly_Report'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType);
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void Mortality ( Hashtable pmCDCQueries )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmCDCQueries;
        //    xlTemplate = clsGbl.tmpFolder + "Mortality Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "Mortality Report\\Mortality Report - " + getRptEnd ( pmCDCQueries ).Year + " " + getRptEnd ( pmCDCQueries ).Month + " " + getRptEnd ( pmCDCQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'Cohort'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    getQueries ( Convert.ToInt32 ( theDr["CatID"].ToString ( ) ), "Mortality" );
        //  }

        //  public void MonthlyReport_Nigeria ( Hashtable pmCDCQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "All Program Areas";
        //    theObject = new Entity ( );
        //    myParameters = pmCDCQueries;
        //    xlTemplate = clsGbl.tmpFolder + "Nigeria MR Template 1.xls";
        //    xlFileName = clsGbl.tmpFolder + "Monthly Report Nigeria\\Monthly Report - " + getRptEnd ( pmCDCQueries ).Year + " " + getRptEnd ( pmCDCQueries ).Month + " " + getRptEnd ( pmCDCQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'Nigeria MR'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    //getQueries(Convert.ToInt32(theDr["CatID"].ToString()), locType, dbSet, cccSet, locTable, false,null);
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void DefaulterReport ( Hashtable pmCDCQueries, string locType, string dbSet, string cccSet, DataTable locTable )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "Defaulter Tracing";
        //    theObject = new Entity ( );
        //    myParameters = pmCDCQueries;
        //    xlTemplate = clsGbl.tmpFolder + "Defaulter Report Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "Defaulter Report\\Defaulter Report - " + getRptEnd ( pmCDCQueries ).Year + " " + getRptEnd ( pmCDCQueries ).Month + " " + getRptEnd ( pmCDCQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'Defaulter'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    getQueries ( Convert.ToInt32 ( theDr["CatID"].ToString ( ) ), locType, dbSet, cccSet, locTable, false, null );
        //  }

        //  public void CustomReport ( Hashtable pmCDCQueries, String reportName, DataTable locTable, bool bySheet )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = reportName;
        //    theObject = new Entity ( );
        //    myParameters = pmCDCQueries;
        //    xlTemplate = clsGbl.tmpFolder + reportName + " Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "Custom Reports\\" + reportName + " - " + getRptEnd ( pmCDCQueries ).Year + " " + getRptEnd ( pmCDCQueries ).Month + " " + getRptEnd ( pmCDCQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "select CatID from aa_CustomReports where ReportName='" + reportName + "'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    getQueries ( Convert.ToInt32 ( theDr["CatID"].ToString ( ) ), "ALL", "", "", locTable, bySheet, null );

        //  }

        //  public void TBRegister ( Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb )
        //  {
        //    DataRow theDr;
        //    xlWorkSheet = "LPTF";
        //    theObject = new Entity ( );
        //    myParameters = pmARQueries;
        //    xlTemplate = clsGbl.tmpFolder + "TB Register Template.xls";
        //    xlFileName = clsGbl.tmpFolder + "TB Summary\\TB Register - " + getRptEnd ( pmARQueries ).Year + " " + getRptEnd ( pmARQueries ).Month + " " + getRptEnd ( pmARQueries ).Day + " - " + getLPTF ( ) + ".xls";
        //    theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams
        //                        , "SELECT CatID FROM aa_Category WHERE Category = 'TBRegister'", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //    int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );
        //    runReport ( catID, locType, dbSet, cccSet, locTable, bySheet, pb );
        //  }

        //  public void HIVQUAL(Hashtable pmARQueries, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pb)
        //  {
        //      DataRow theDr;
        //      xlWorkSheet = "Summary_Report";
        //      theObject = new Entity();
        //      myParameters = pmARQueries;
        //      xlTemplate = clsGbl.tmpFolder + "HIVQUAL Template.xls";
        //      xlFileName = clsGbl.tmpFolder + "HIVQUAL Reports\\HIVQUAL Summary - " + 
        //                      getRptEnd(pmARQueries).Year + " " +
        //                      getRptEnd(pmARQueries).Month + " - " + getLPTF() + ".xls";
        //      theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams
        //                      , "SELECT CatID FROM aa_Category WHERE Category = 'HIVQUAL'"
        //                      , ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType);       
        //      int catID = Convert.ToInt32(theDr["CatID"].ToString());
        //      runReport(catID, locType, dbSet, cccSet, locTable, bySheet, pb);
        //  }

        //  #endregion Reports

        //  public void runReport(int catID, string locType, string dbSet, string cccSet, DataTable locTable, Boolean bySheet, ProgressBar pr)
        //  {
        //      Thread reportRunner = new Thread(() => getQueries(catID, locType, dbSet, cccSet, locTable, bySheet, pr));
        //      reportRunner.SetApartmentState(ApartmentState.STA);
        //      try
        //      {
        //          // TODO CHRIS Check if reportRunner is Alive before starting it
        //          reportRunner.Start();
        //      }
        //      catch (Exception ex) { MessageBox.Show(ex.Message); }
        //  }

        //  public string adherence ( string Def, Hashtable pmAdherence )
        //  {
        //    myParameters = pmAdherence;
        //    return SQLString ( Def );
        //  }

        //  private bool addReportHeader ( )
        //  {
        //    bool success = false;
        //    try
        //    {
        //      //  oWs.Rows.Insert(Excel.XlInsertShiftDirection.xlShiftDown,);
        //      Excel.Range rn;

        //      rn = oWs.get_Range ( "A1", Type.Missing );
        //      //insert first row
        //      rn.EntireRow.Insert ( Excel.XlInsertShiftDirection.xlShiftDown, Type.Missing );
        //      rn = oWs.get_Range ( "A1", Type.Missing );
        //      rn.Value2 = 0;
        //      rn.Value2 = "IQTools Version: " + clsGbl.IQToolsVersion;
        //      rn.WrapText = false;
        //      //insert second row
        //      rn.EntireRow.Insert ( Excel.XlInsertShiftDirection.xlShiftDown, Type.Missing );
        //      rn = oWs.get_Range ( "A1", Type.Missing );
        //      rn.Value2 = 0;
        //      rn.Value2 = "Report Date: " + DateTime.Now;
        //      rn.WrapText = false;

        //      //  rn.Rows.Insert(Excel.XlInsertShiftDirection.xlShiftDown, Type.Missing);


        //    }
        //    catch
        //    {
        //      success = false;
        //    }

        //    return success;

        //  }

        //  private string getLPTF ( )
        //  {
        //    DataRow theDr;
        //    theObject = new Entity ( ); ClsUtility.Init_Hashtable ( );
        //    try
        //    {
        //      if (clsGbl.PMMSType.ToLower ( ) == "mysql")
        //      {
        //          theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams
        //              , "SELECT FacilityName From IQC_SiteDetails Limit 1"
        //          , ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType); 
        //      }
        //      else 
        //      { 
        //          theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams
        //          , "SELECT Top 1 FacilityName From IQC_siteDetails Order by FacilityID", ClsUtility.ObjectEnum.DataRow, "mssql" ); }

        //      if (theDr["FacilityName"].ToString ( ).Length >= 20)
        //      { return theDr["FacilityName"].ToString ( ).Substring ( 0, 20 ); }
        //      else
        //      { return theDr["FacilityName"].ToString ( ); }
        //    }
        //    catch { }

        //    return "";
        //  }

        //  private DateTime getRptEnd ( Hashtable x )
        //  {
        //    string periodEnd = "";
        //    foreach (DictionaryEntry hk in x)
        //    {
        //      if (hk.Key.ToString ( ).ToLower ( ).Trim ( ) == "@todate")
        //      {
        //        periodEnd = hk.Value.ToString ( );
        //        break;
        //      }
        //    }
        //    if (periodEnd == "")
        //      return DateTime.Today;
        //    else
        //      return Convert.ToDateTime ( periodEnd );

        //  }

        public void ExportToExcel(DataTable dt, string Path)
        {
            var rowCount = dt.Rows.Count;
            string finalFileNameWithPath = string.Empty;

            string myDocsPath = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            finalFileNameWithPath = myDocsPath + "\\IQTools Reports\\Excel Exports\\" + clsGbl.loggedInUser.FacilityName + " - ClinicalData.xlsx";

            //Delete existing file with same file name.
            if (File.Exists(finalFileNameWithPath))
                File.Delete(finalFileNameWithPath);

            var newFile = new FileInfo(finalFileNameWithPath);
            newFile.Directory.Create();
            using (var package = new ExcelPackage(newFile))
            {
                ExcelWorksheet worksheet = package.Workbook.Worksheets.Add("IQTools");

                worksheet.Cells["A1"].LoadFromDataTable(dt, true, TableStyles.Medium2);
                var dateColumns = from DataColumn d in dt.Columns
                                  where d.DataType == typeof(DateTime) || d.ColumnName.Contains("Date")
                                  select d.Ordinal + 1;

                foreach (var dc in dateColumns)
                {
                    worksheet.Cells[2, dc, rowCount + 1, dc].Style.Numberformat.Format = "dd/mm/yyyy";
                }
                worksheet.Cells[worksheet.Dimension.Address].AutoFitColumns();

                package.Save();
                System.Diagnostics.Process.Start(finalFileNameWithPath);
            }
        }

        public void ExportToExcel(DataTable queryOutput, DataTable statistics, string Path)
        {
            //Overloading the ExportToExcel method to allow exporting query statistics to new worksheet

            var rowCount = queryOutput.Rows.Count;
            //string fileName = "Clinical Data";
            string finalFileNameWithPath = string.Empty;

            //fileName = string.Format("{0}", fileName);
            //finalFileNameWithPath = string.Format("{0}\\{1}.xlsx", Path, fileName);

            string myDocsPath = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            finalFileNameWithPath = myDocsPath + "\\IQTools Reports\\Excel Exports\\" + clsGbl.loggedInUser.FacilityName + " - QueryData.xlsx";

            //Delete existing file with same file name.
            if (File.Exists(finalFileNameWithPath))
                File.Delete(finalFileNameWithPath);

            var newFile = new FileInfo(finalFileNameWithPath);
            newFile.Directory.Create();
            using (var package = new ExcelPackage(newFile))
            {
                ExcelWorksheet worksheet = package.Workbook.Worksheets.Add("IQTools");
                ExcelWorksheet stats = package.Workbook.Worksheets.Add("OutputAnalysis");
                worksheet.Cells["A1"].LoadFromDataTable(queryOutput, true, TableStyles.Medium2);
                var dateColumns = from DataColumn d in queryOutput.Columns
                                  where d.DataType == typeof(DateTime) || d.ColumnName.Contains("Date")
                                  select d.Ordinal + 1;

                foreach (var dc in dateColumns)
                {
                    worksheet.Cells[2, dc, rowCount + 1, dc].Style.Numberformat.Format = "dd/mm/yyyy";
                }
                worksheet.Cells[worksheet.Dimension.Address].AutoFitColumns();

                stats.Cells["A1"].LoadFromDataTable(statistics, true, TableStyles.Medium2);
                stats.Cells[worksheet.Dimension.Address].AutoFitColumns();

                package.Save();
                System.Diagnostics.Process.Start(finalFileNameWithPath);
            }
        }

        //  public void ExportExcel ( DataTable dt, string flName )
        //  {
        //    try
        //    {
        //      Excel.Application oApp; Excel.Range oRange;
        //      Excel.Workbook oBook; Excel.Worksheet oSheet;

        //      try
        //      { File.Delete ( flName ); }
        //      catch { }

        //      oApp = new Excel.Application ( );
        //      oBook = oApp.Workbooks.Add ( Type.Missing );
        //      oSheet = (Excel.Worksheet)oBook.ActiveSheet;
        //      oSheet.Name = "IQTools";

        //      try
        //      {
        //        foreach (Excel.Worksheet ws in oBook.Worksheets)
        //        {
        //          if (ws.Name != "IQTools")
        //            ws.Delete ( );
        //        }
        //      }
        //      catch { }

        //      oApp.Visible = false; int iRow = 2;

        //      for (int j = 0; j < dt.Columns.Count; j++)
        //      { oSheet.Cells[1, j + 1] = dt.Columns[j].ColumnName; }

        //      for (int rowNo = 0; rowNo < dt.Rows.Count; rowNo++)
        //      {
        //        for (int colNo = 0; colNo < dt.Columns.Count; colNo++)
        //        { oSheet.Cells[iRow, colNo + 1] = dt.Rows[rowNo][colNo].ToString ( ); }
        //        iRow++;
        //      }

        //      oRange = oSheet.get_Range ( oSheet.Cells[1, 1], oSheet.Cells[1, dt.Columns.Count] );
        //      oRange.Font.Bold = true;

        //      oRange = oSheet.get_Range ( oSheet.Cells[1, 1], oSheet.Cells[dt.Rows.Count, dt.Columns.Count] );
        //      oRange.EntireColumn.AutoFit ( );

        //      oSheet = null;
        //      oRange = null;
        //      //String password;
        //      //password = "Futures";
        //      oBook.SaveAs ( flName, Excel.XlFileFormat.xlWorkbookNormal,
        //          Type.Missing, Type.Missing, Type.Missing, Type.Missing,
        //          Excel.XlSaveAsAccessMode.xlExclusive,
        //          Type.Missing, Type.Missing, Type.Missing,
        //          Type.Missing, Type.Missing );
        //      oBook.Close ( Type.Missing, Type.Missing, Type.Missing );
        //      oBook = null;
        //      oApp.Quit ( );

        //      System.Diagnostics.Process.Start ( flName );
        //    }
        //    catch { }
        //  }

        //  private void UpdateProgress ( int p, ProgressBar pr )
        //  {
        //    if (pr == null) return;

        //    if (pr.InvokeRequired)
        //    { pr.Invoke ( new MethodInvoker ( delegate { pr.Value = p; } ) ); }
        //  }

        //  private void getQueries ( Int32 mReport, string locType, string dbSet, string CCC, DataTable LocTable, Boolean xlSheet, ProgressBar pr )
        //  {
        //    DataTable theDt = new DataTable ( ); DataTableReader theDr; DataTableReader dTr;
        //    theObject = new Entity ( ); ClsUtility.Init_Hashtable ( );
        //    resetDHIS2DataTable ( );
        //    try
        //    {
        //        oExcel = new Excel.Application(); //setting the excel files
        //        oExcel.Visible = false;
        //        oBook = (Excel.Workbook)oExcel.Workbooks.Open(xlTemplate, Type.Missing, Type.Missing,
        //                   Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing,
        //                   Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing,
        //                   Type.Missing, Type.Missing);
        //        oWs = (Excel.Worksheet)oBook.Worksheets[xlWorkSheet];

        //        //Unprotect WorkSheet Before Populating

        //      //  if (oWs.ProtectContents)
        //       //     oWs.Unprotect(clsGbl.ReportPassword);

        //        if (xlSheet)
        //        {
        //            dTr = LocTable.CreateDataReader();
        //            if (locType.ToLower() == "lptf")
        //            {
        //                while (dTr.Read())
        //                {
        //                    if (LocTable != null)
        //                    {
        //                        oWs.Copy(Type.Missing, oBook.Worksheets[(oBook.Worksheets.Count)]);
        //                        tWs = (Excel.Worksheet)oBook.Worksheets[oBook.Worksheets.Count];
        //                        if (dTr[0].ToString().Length > 28)
        //                        { tWs.Name = dTr[0].ToString().Substring(0, 29).Replace("/", "").Replace("\\", "").Replace("*", "").Replace("?", "").Replace("[", "").Replace("]", ""); }
        //                        else { tWs.Name = dTr[0].ToString().Replace("/", "").Replace("\\", "").Replace("*", "").Replace("?", "").Replace("[", "").Replace("]", ""); }
        //                    }
        //                }
        //                dTr.Close(); dTr.Dispose();
        //            }
        //            theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams
        //                                    , "SELECT DISTINCT a.QryID, a.sbCatID " +
        //                                    "FROM aa_SBCategory a INNER JOIN  aa_Category b ON a.CatID = b.CatID " +
        //                                    "WHERE a.QryID Is Not Null And b.CatID=" + mReport
        //                                    , ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType);

        //            theDr = theDt.CreateDataReader();
        //            DataRow dr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams
        //                                        , "SELECT Count(QryID) Total FROM " +
        //                                        "aa_SBCategory a INNER JOIN  aa_Category b ON a.CatID = b.CatID WHERE a.QryID Is Not Null " +
        //                                        " AND b.CatID=" + mReport
        //                                        , ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType);
        //            int numberOfQueries = Convert.ToInt32(dr[0].ToString());
        //            double queryCounter = 0;
        //            double progress = 0;
        //            string wShtName = "";

        //            while (theDr.Read())
        //            {
        //                queryCounter = queryCounter + 1;
        //                double div = queryCounter / numberOfQueries;
        //                progress = div * 100;
        //                UpdateProgress((int)progress, pr);
        //                execQuery(theDr["sbCatID"].ToString(), theDr["QryID"].ToString(), "", dbSet);
        //                dTr = LocTable.CreateDataReader();
        //                while (dTr.Read())
        //                {
        //                    if (dTr[0].ToString().Length > 28)
        //                    { wShtName = dTr[0].ToString().Substring(0, 29).Replace("/", "").Replace("\\", "").Replace("*", "").Replace("?", "").Replace("[", "").Replace("]", ""); }
        //                    else { wShtName = dTr[0].ToString().Replace("/", "").Replace("\\", "").Replace("*", "").Replace("?", "").Replace("[", "").Replace("]", ""); }

        //                    oWs = (Excel.Worksheet)oBook.Worksheets[wShtName];
        //                    CCC = dTr[0].ToString();
        //                    execQuery(theDr["sbCatID"].ToString(), theDr["QryID"].ToString(), CCC, dbSet);
        //                }
        //                oWs = (Excel.Worksheet)oBook.Worksheets[xlWorkSheet];
        //            }
        //        }
        //        else
        //        {
        //            theDt = new DataTable();
        //            theObject = new Entity(); ClsUtility.Init_Hashtable();
        //            theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams
        //                                        , "SELECT DISTINCT QryID, sbCatID " +
        //                                         "FROM aa_SBCategory a INNER JOIN  aa_Category b ON a.CatID = b.CatID " +
        //                                         "WHERE a.QryID Is Not Null And b.CatID=" + mReport
        //                                         , ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType);
        //            theDr = theDt.CreateDataReader();

        //            DataRow dr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams
        //                                        , "SELECT Count(QryID) Total FROM " +
        //                                        "aa_SBCategory a INNER JOIN  aa_Category b ON a.CatID = b.CatID WHERE a.QryID Is Not Null " +
        //                                        " AND b.CatID=" + mReport, ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType);

        //            int numberOfQueries = Convert.ToInt32(dr[0].ToString());
        //            double queryCounter = 0;
        //            double progress = 0;

        //            if (locType.ToLower() == "all" || locType.ToLower() == "allrc" || locType.ToLower() == "allcr")
        //            {
        //                while (theDr.Read())
        //                {
        //                    if (locType.ToLower() == "all")
        //                    {
        //                        queryCounter = queryCounter + 1;
        //                        double div = queryCounter / numberOfQueries;
        //                        progress = div * 100;
        //                        UpdateProgress((int)progress, pr);
        //                    }
        //                    execQuery(theDr["sbCatID"].ToString(), theDr["QryID"].ToString(), "", "");
        //                }
        //            }
        //            else if (locType.ToLower() == "lptf")
        //            {
        //                while (theDr.Read())
        //                {
        //                    queryCounter = queryCounter + 1;
        //                    double div = queryCounter / numberOfQueries;
        //                    progress = div * 100;
        //                    UpdateProgress((int)progress, pr);
        //                    execQuery(theDr["sbCatID"].ToString(), theDr["QryID"].ToString(), "", dbSet);

        //                    if (LocTable != null)
        //                    {
        //                        if (LocTable.Rows.Count > 1)
        //                        {
        //                            execQuery(theDr["sbCatID"].ToString(), theDr["QryID"].ToString(), dbSet, LocTable, false);
        //                        }
        //                    }
        //                }
        //            }

        //            else if (locType.ToLower() == "ccc")
        //            {
        //                while (theDr.Read())
        //                {
        //                    queryCounter = queryCounter + 1;
        //                    double div = queryCounter / numberOfQueries;
        //                    progress = div * 100;
        //                    UpdateProgress((int)progress, pr);
        //                    execQuery(theDr["sbCatID"].ToString(), theDr["QryID"].ToString(), CCC, dbSet);
        //                }
        //            }

        //            if (clsGbl.IQDirection.Length > 3 && clsGbl.IQDirection.Substring(0, 4).ToLower() == "arts")
        //            {
        //                string tblName = "IQC_corePatientLineList"; Excel._Worksheet oWorkSheet;
        //                oWorkSheet = (Excel.Worksheet)oBook.Worksheets["Source"]; oWorkSheet.Activate();

        //                theDt.Clear();
        //                theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams
        //                    , "SELECT * FROM " + tblName, ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType);
        //                int iRow = 2;

        //                if (theDt.Rows.Count > 0)
        //                {
        //                    for (int j = 0; j < theDt.Columns.Count; j++)
        //                    { oWorkSheet.Cells[1, j + 1] = theDt.Columns[j].ColumnName; }

        //                    for (int rowNo = 0; rowNo < theDt.Rows.Count; rowNo++)
        //                    {
        //                        for (int colNo = 0; colNo < theDt.Columns.Count; colNo++)
        //                        { oWorkSheet.Cells[iRow, colNo + 1] = theDt.Rows[rowNo][colNo].ToString(); }
        //                        iRow++;
        //                    }
        //                }
        //            }
        //            clsGbl.IQDirection = "";
        //        }

        //        if (locType.ToLower() == "allrc" || locType.ToLower() == "allcr")
        //        {
        //            string listQueries = "";
        //            if (locType.ToLower() == "allcr")
        //                listQueries = "Cohort Line List";
        //            else if (locType.ToLower() == "allrc")
        //                listQueries = "RC Lists";
        //            try
        //            {
        //                Excel.Worksheet newWorkSheet;
        //                DataTable dt;
        //                DataTable qryDt;
        //                DataTableReader qryDtr;
        //                string theQryID;
        //                string wshtName;
        //                Excel.Range oRange;
        //                qryDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams
        //                    , "SELECT DISTINCT aa_Queries.qryID, aa_Queries.QryDescription FROM aa_Queries " +
        //                    "inner join aa_SBCategory on aa_Queries.qryid = aa_SBCategory.qryid where sbCategory = '" + listQueries + "'" +
        //                    "", ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType);
        //                qryDtr = qryDt.CreateDataReader();

        //                DataRow dr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams
        //                    , "SELECT Count(aa_Queries.QryID) Total FROM aa_Queries " +
        //                    "inner join aa_SBCategory on aa_Queries.qryid = aa_SBCategory.qryid where sbCategory = '" + listQueries + "'" +
        //                    "", ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType);

        //                int numberOfQueries = Convert.ToInt32(dr[0].ToString());
        //                double queryCounter = 0;
        //                double progress = 0;

        //                while (qryDtr.Read())
        //                {
        //                    queryCounter = queryCounter + 1;
        //                    double div = queryCounter / numberOfQueries;
        //                    progress = div * 100;
        //                    UpdateProgress((int)progress, pr);
        //                    theQryID = qryDtr["QryID"].ToString().Trim();
        //                    wshtName = qryDtr["QryDescription"].ToString().Substring(28, qryDtr["QryDescription"].ToString().Length - 28);
        //                    dt = (DataTable)execLineLists(theQryID);
        //                    int count = oBook.Worksheets.Count;
        //                    newWorkSheet = (Excel.Worksheet)oBook.Worksheets.Add(Type.Missing, oBook.Worksheets[count], Type.Missing, Type.Missing);

        //                    if (wshtName.Length <= 31)
        //                    {
        //                        newWorkSheet.Name = wshtName;
        //                    }
        //                    else newWorkSheet.Name = wshtName.Substring(0, 31);
        //                    int iRow = 2;
        //                    for (int j = 0; j < dt.Columns.Count; j++)
        //                    { newWorkSheet.Cells[1, j + 1] = dt.Columns[j].ColumnName.ToString().ToUpper(); }

        //                    for (int rowNo = 0; rowNo < dt.Rows.Count; rowNo++)
        //                    {
        //                        for (int colNo = 0; colNo < dt.Columns.Count; colNo++)
        //                        { newWorkSheet.Cells[iRow, colNo + 1] = dt.Rows[rowNo][colNo].ToString(); }
        //                        iRow++;
        //                    }

        //                    oRange = newWorkSheet.get_Range(newWorkSheet.Cells[1, 1], newWorkSheet.Cells[1, dt.Columns.Count]);
        //                    oRange.Font.Bold = true;
        //                    oRange.BorderAround(Excel.XlLineStyle.xlContinuous, Excel.XlBorderWeight.xlThin, Excel.XlColorIndex.xlColorIndexAutomatic, 1);
        //                    oRange.Interior.Color = 16777164;

        //                    oRange = newWorkSheet.get_Range(newWorkSheet.Cells[1, 1], newWorkSheet.Cells[dt.Rows.Count + 1, dt.Columns.Count]);
        //                    oRange.EntireColumn.AutoFit();
        //                    oRange.BorderAround(Excel.XlLineStyle.xlContinuous, Excel.XlBorderWeight.xlThin, Excel.XlColorIndex.xlColorIndexAutomatic, 1);

        //                    newWorkSheet = null;
        //                    oRange = null;
        //                    dt.Clear();
        //                }
        //                qryDt.Clear();
        //            }
        //            catch (Exception ex)
        //            { MessageBox.Show(ex.Message); }
        //        }
        //        try
        //        {
        //            try
        //            {
        //                if (File.Exists(xlFileName))
        //                {
        //                    File.Delete(xlFileName);
        //                }
        //            }
        //            catch { }
        //            addReportHeader();

        //            if (!oWs.ProtectContents)
        //                oWs.Protect(clsGbl.ReportPassword);
        //            string ext = Path.GetExtension ( xlFileName );
        //            if (ext == ".xlsx")
        //            {
        //              oWs = (Excel.Worksheet)oBook.Worksheets.get_Item ( 1 );
        //              if (oWs.Name.ToLower ( ) == "lptf") oWs.Name = "Apr 2015 - Jun 2015";  // Quick fix for exporting xlxs which needs to be imported in another system the that given sheet name : @Victor to set this dynamic
        //              oBook.SaveAs ( xlFileName, Excel.XlFileFormat.xlOpenXMLWorkbook, null, null, false, false, Excel.XlSaveAsAccessMode.xlNoChange, Excel.XlSaveConflictResolution.xlUserResolution, true, null, null, null );
        //            }
        //            else
        //            {
        //              oBook.SaveAs ( xlFileName, Excel.XlFileFormat.xlWorkbookNormal, null, null, false, false, Excel.XlSaveAsAccessMode.xlNoChange, false, false, null, null, null );
        //            }
        //        }
        //        catch (Exception ex)
        //        { MessageBox.Show(ex.Message); }

        //        oBook.Close(false, Type.Missing, Type.Missing);
        //        oExcel.Quit(); oExcel = null;
        //        if (bPatSummaryBulkReport == false)
        //        {
        //            System.Diagnostics.Process.Start(xlFileName);
        //        }
        //        if (clsGbl.sendToDHIS)
        //        {
        //            XmlDocument doc = createDHIS2XMLFile();
        //            pstXML(DHIS2URL + "/api/dataValueSets", doc, DHIS2Credentials);
        //            //http://test.hiskenya.org/api/dataValueSets
        //        }
        //    }
        //    catch (Exception ex) { MessageBox.Show(ex.Message); }
        //  }

        //  private void getQueries ( Int32 mReport )
        //  {
        //    //bool mErrors;
        //    oExcel = new Excel.Application ( ); //setting the excel files
        //    oExcel.Visible = false;
        //    oBook = (Excel.Workbook)oExcel.Workbooks.Open ( xlTemplate, Type.Missing, Type.Missing,
        //               Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing,
        //               Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing,
        //               Type.Missing, Type.Missing );
        //    oWs = (Excel.Worksheet)oBook.Worksheets[xlWorkSheet];




        //    // get the queries categories;
        //    DataTable theDt = new DataTable ( ); DataTableReader theDr;
        //    theObject = new Entity ( ); ClsUtility.Init_Hashtable ( );

        //    // load queries based on the selected check box in location page

        //    theDt = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT DISTINCT QryID, sbCatID " +
        //        "FROM aa_SBCategory INNER JOIN  aa_Category ON aa_SBCategory.CatID = aa_Category.CatID " +
        //        "WHERE QryID Is Not Null And aa_Category.CatID=" + mReport, ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //    theDr = theDt.CreateDataReader ( );

        //    while (theDr.Read ( ))
        //    {
        //      execQuery ( theDr["sbCatID"].ToString ( ), theDr["QryID"].ToString ( ), "", "" );

        //    }

        //    # region source data for ART start ...
        //    if (clsGbl.IQDirection.Substring ( 0, 4 ).ToLower ( ) == "arts")
        //    {
        //      //Excel.Range oRange;

        //      string tblName = "PMT_0001i"; Excel._Worksheet oWorkSheet;
        //      oWorkSheet = (Excel.Worksheet)oBook.Worksheets["Source"]; oWorkSheet.Activate ( );

        //      theDt.Clear ( );
        //      theDt = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT * FROM " + tblName, ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //      int iRow = 2;

        //      if (theDt.Rows.Count > 0)
        //      {
        //        for (int j = 0; j < theDt.Columns.Count; j++)
        //        { oWorkSheet.Cells[1, j + 1] = theDt.Columns[j].ColumnName; }

        //        for (int rowNo = 0; rowNo < theDt.Rows.Count; rowNo++)
        //        {
        //          for (int colNo = 0; colNo < theDt.Columns.Count; colNo++)
        //          { oWorkSheet.Cells[iRow, colNo + 1] = theDt.Rows[rowNo][colNo].ToString ( ); }
        //          iRow++;
        //        }
        //      }
        //    }
        //    clsGbl.IQDirection = "";
        //    #endregion

        //    try
        //    { oBook.SaveAs ( xlFileName, Excel.XlFileFormat.xlWorkbookNormal, null, null, false, false, Excel.XlSaveAsAccessMode.xlNoChange, false, false, null, null, null ); }
        //    catch (Exception ex)
        //    { MessageBox.Show ( ex.Message ); }
        //    oBook.Close ( false, Type.Missing, Type.Missing );
        //    oExcel.Quit ( ); oExcel = null;
        //    System.Diagnostics.Process.Start ( xlFileName );
        //  }

        //  private void getQueries ( Int32 mReport, string oParams )
        //  {
        //    //bool mErrors;
        //    oExcel = new Excel.Application ( ); //setting the excel files
        //    oExcel.Visible = false;
        //    oBook = (Excel.Workbook)oExcel.Workbooks.Open ( xlTemplate, Type.Missing, Type.Missing,
        //               Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing,
        //               Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing,
        //               Type.Missing, Type.Missing );
        //    oWs = (Excel.Worksheet)oBook.Worksheets[xlWorkSheet];



        //    // get the queries categories;
        //    DataTable theDt = new DataTable ( ); DataTableReader theDr;
        //    theObject = new Entity ( ); ClsUtility.Init_Hashtable ( );

        //    theDt = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT DISTINCT QryID, sbCatID, sbCategory " +
        //        "FROM aa_SBCategory INNER JOIN  aa_Category ON aa_SBCategory.CatID = aa_Category.CatID " +
        //        "WHERE QryID Is Not Null And aa_Category.CatID=" + mReport, ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //    theDr = theDt.CreateDataReader ( );

        //    while (theDr.Read ( ))
        //    {
        //      int f = 1;
        //      if (oParams.ToLower ( ) == "lptf")
        //      {
        //        if (oParams.ToLower ( ) == theDr["sbCategory"].ToString ( ).ToLower ( ))
        //        {
        //          DataTable dt = new DataTable ( ); DataTableReader dtr; theObject = new Entity ( ); ClsUtility.Init_Hashtable ( );

        //          dt = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT * FROM mst_Facility", ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //          dtr = dt.CreateDataReader ( );
        //          f = 1;
        //          while (dtr.Read ( ))
        //          {
        //            // do something here
        //            try
        //            {
        //              myParameters.Remove ( "@lptf" );
        //              myParameters.Add ( "@lptf", dtr["FacilityName"] );
        //            }
        //            catch { }
        //            execQuery ( theDr["sbCatID"].ToString ( ), theDr["QryID"].ToString ( ), f );
        //            f++;

        //          }
        //        }
        //      }
        //      else if (oParams.ToLower ( ) == "mortality")
        //      {
        //        execQuery ( theDr["sbCatID"].ToString ( ), theDr["QryID"].ToString ( ), f );

        //      }
        //      else
        //      {
        //        execQuery ( theDr["sbCatID"].ToString ( ), theDr["QryID"].ToString ( ), "", "" );
        //      }

        //    }

        //    string tblName = "";
        //    if (clsGbl.IQDirection == "ARTStart_IQCare") tblName = "IQC_0105";
        //    else if (clsGbl.IQDirection == "ARTStart_IQCare") tblName = "IQH_0001";

        //    if (clsGbl.IQDirection.Substring ( 0, 8 ).ToLower ( ) == "artstart")
        //    {
        //      // populate the source data in a separate worksheet.
        //      Excel._Worksheet oWorkSheet;
        //      oWorkSheet = (Excel.Worksheet)oBook.Worksheets["Source"];
        //      oWorkSheet.Activate ( );

        //      theDt.Clear ( );
        //      theDt = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT * FROM " + tblName, ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //      int iRow = 2;

        //      //check for data
        //      if (theDt.Rows.Count > 0)
        //      {
        //        for (int j = 0; j < theDt.Columns.Count; j++)
        //        { oWorkSheet.Cells[1, j + 1] = theDt.Columns[j].ColumnName; }

        //        for (int rowNo = 0; rowNo < theDt.Rows.Count; rowNo++)
        //        {
        //          for (int colNo = 0; colNo < theDt.Columns.Count; colNo++)
        //          { oWorkSheet.Cells[iRow, colNo + 1] = theDt.Rows[rowNo][colNo].ToString ( ); }
        //          iRow++;
        //        }
        //      }
        //    }

        //    clsGbl.IQDirection = "";
        //    try
        //    { oBook.SaveAs ( xlFileName, Excel.XlFileFormat.xlWorkbookNormal, null, null, false, false, Excel.XlSaveAsAccessMode.xlNoChange, false, false, null, null, null ); }
        //    catch (Exception ex)
        //    { MessageBox.Show ( ex.Message ); }
        //    oBook.Close ( false, Type.Missing, Type.Missing );
        //    oExcel.Quit ( ); oExcel = null;
        //    System.Diagnostics.Process.Start ( xlFileName );
        //    if (clsGbl.sendToDHIS)
        //    {
        //      XmlDocument doc = createDHIS2XMLFile ( );
        //      // TODO VY uncoment this 

        //      pstXML ( DHIS2URL + "/api/dataValueSets", doc, DHIS2Credentials );
        //      //http://test.hiskenya.org/api/dataValueSets
        //    }
        //  }

        //  private object execLineLists ( string QryID )
        //  {
        //    DataRow theQry;
        //    Entity theObject = new Entity ( );
        //    //ClsUtility.Init_Hashtable();
        //    DataTable tmpDT = new DataTable ( );
        //    try
        //    {
        //      theQry = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT  QryDefinition From aa_Queries Where QryID= " + QryID, ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );

        //      //tmpDT = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, SQLString(theQry["qryDefinition"].ToString().ToLower().Trim()), ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType); 
        //      tmpDT = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, SQLString ( theQry["qryDefinition"].ToString ( ).Trim ( ) ), ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //      return tmpDT;

        //    }
        //    catch (Exception ex)
        //    {
        //      MessageBox.Show ( ex.Message );
        //      tmpDT = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "Select 'Error'", ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //      return tmpDT;
        //    }

        //  }

        //  private bool execQuery ( string xlCatID, string QryID, string CCC, string dbSet )
        //  {
        //    string srcQuery = ""; DataRow theQry; string newQuery = ""; string modQuery = "";
        //    Entity theObject = new Entity ( ); ClsUtility.Init_Hashtable ( );
        //    try
        //    {
        //      theQry = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath )
        //                      , ClsUtility.theParams, "SELECT  QryName, qryDefinition From aa_Queries Where QryID= " + QryID
        //                      , ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //      srcQuery = theQry["QryName"].ToString ( );
        //      if (clsGbl.PMMSType.ToLower ( ) != "mysql")
        //        newQuery = theQry["qryDefinition"].ToString ( ).ToLower ( );
        //      else
        //        newQuery = theQry["qryDefinition"].ToString ( );

        //      if (dbSet != "" && CCC == "")
        //      {
        //        srcQuery = srcQuery + "_i";
        //        modQuery = newQuery.Replace ( "where", "where facilityname = @lptf and" );
        //      }
        //      else if (dbSet != "" && CCC != "")
        //      {
        //        srcQuery = srcQuery + "_ii";
        //        modQuery = newQuery.Replace ( "where", "where facilityname = @lptf and satellitename = @ccc and" );
        //      }
        //      else
        //      {
        //        modQuery = newQuery;
        //      }
        //      DataTable tmpDT = new DataTable ( );
        //      tmpDT = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath )
        //                  , ClsUtility.theParams, SQLString ( modQuery.Trim ( ), CCC, dbSet )
        //                  , ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );

        //      return mapQuery ( tmpDT, QryID, xlCatID );

        //    }
        //    catch { return false; }
        //  }

        //  private bool execQuery ( string xlCatID, string QryID, int posID )
        //  {
        //    DataRow dr;
        //    Entity theObject = new Entity ( ); ClsUtility.Init_Hashtable ( );

        //    try
        //    {
        //      DataTable tmpDT = new DataTable ( );
        //      dr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT  qryDefinition, sbCategory FROM aa_Queries INNER JOIN aa_SBCategory ON aa_Queries.QryID = aa_SBCategory.QryID WHERE  sbCatID=" + xlCatID + " AND aa_SBCategory.QryID= " + QryID, ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //      tmpDT = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, SQLString ( dr["qryDefinition"].ToString ( ).ToLower ( ).Trim ( ) ), ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //      return mapQuery ( tmpDT, QryID, xlCatID, posID );
        //    }
        //    catch (Exception ex)
        //    {
        //      throw ex;
        //    }
        //  }

        //  private bool execQuery ( string xlCatID, string QryID, string dbSet, DataTable CCCs, Boolean sheet )
        //  {
        //    DataRow dr; DataTableReader myDtr; int i = 0; string newQuery = ""; string modQuery = "";
        //    Entity theObject = new Entity ( ); ClsUtility.Init_Hashtable ( );
        //    myDtr = CCCs.CreateDataReader ( ); DataRow theQry;

        //    try
        //    {        
        //      string srcQuery = "";
        //      theQry = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams
        //          , "SELECT  QryName, QryDefinition From aa_Queries Where QryID= " + QryID, ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //      srcQuery = theQry["QryName"].ToString ( );
        //      newQuery = theQry["qryDefinition"].ToString ( ).ToLower ( );
        //      modQuery = newQuery.Replace ( "where", "where facilityname = @lptf and satellitename = @ccc and" );
        //      srcQuery = srcQuery + "_ii";
        //      while (myDtr.Read ( ))
        //      {
        //        DataTable tmpDT = new DataTable ( ); i++;
        //        dr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams
        //            , "SELECT  qryDefinition, sbCategory FROM aa_Queries INNER JOIN aa_SBCategory ON aa_Queries.QryID = aa_SBCategory.QryID WHERE  sbCatID=" + 
        //            xlCatID + " AND aa_SBCategory.QryID= " + QryID, ClsUtility.ObjectEnum.DataRow, clsGbl.PMMSType );
        //        tmpDT = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams
        //            , SQLString ( modQuery.Trim ( ), myDtr["Facility"].ToString ( ), dbSet ), ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //        mapQuery ( tmpDT, QryID, xlCatID, 0, i, sheet );
        //      }
        //      return true;
        //    }
        //    catch { }

        //    return true;
        //  }

        //  private bool mapQuery ( DataTable qryResult, string qryID, string xlID, int posID )
        //  {
        //    Entity theObject = new Entity ( ); ClsUtility.Init_Hashtable ( );
        //    try
        //    {
        //      if (qryResult.Rows.Count > 0)
        //      {
        //        DataTable theDt; Excel.Range rn;

        //        theDt = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams
        //            , "SELECT xlsCell, xlsTitle FROM aa_XLMaps WHERE QryID= " + qryID + " AND xlCatID=" + xlID, ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //        DataTableReader dr = theDt.CreateDataReader ( );
        //        DataTableReader theDr; int cRow = 0; int cCol = 0;
        //        while (dr.Read ( ))
        //        {
        //          for (int i = 0; i < qryResult.Columns.Count; i++)
        //          {
        //            theDr = qryResult.CreateDataReader ( );
        //            if (qryResult.Columns[i].ColumnName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //            {
        //              cRow = 0;
        //              cCol = 0;

        //              cRow = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing ).Row;
        //              cCol = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing ).Column;

        //              if (cCol >= 4) cCol = 4;

        //              while (theDr.Read ( ))
        //              {
        //                if (qryResult.Rows.Count == 1)
        //                {
        //                  rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                  rn.get_Offset ( posID, 0 ).BorderAround ( Type.Missing, Excel.XlBorderWeight.xlThin
        //                      , Excel.XlColorIndex.xlColorIndexAutomatic, Type.Missing );
        //                  rn.get_Offset ( posID, 0 ).set_Value ( m_objOpt, theDr[i].ToString ( ) );
        //                  break;
        //                }
        //                if (theDr.FieldCount == 3 && (theDr.GetName ( 0 ).ToLower ( ) == "result" 
        //                    || theDr.GetName ( 1 ).ToLower ( ) == "result" || theDr.GetName ( 2 ).ToLower ( ) == "result"))
        //                {
        //                  rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                  rn.get_Offset ( posID, 0 ).BorderAround ( Type.Missing, Excel.XlBorderWeight.xlThin, Excel.XlColorIndex.xlColorIndexAutomatic, Type.Missing );
        //                  rn.get_Offset ( posID, 0 ).set_Value ( m_objOpt, theDr["Result"].ToString ( ) );
        //                  break;

        //                }
        //                else
        //                {
        //                  rn = (Excel.Range)oWs.Cells[cRow, cCol];
        //                  rn.BorderAround ( Type.Missing, Excel.XlBorderWeight.xlThin, Excel.XlColorIndex.xlColorIndexAutomatic, Type.Missing );
        //                  rn.set_Value ( m_objOpt, theDr[i].ToString ( ) );
        //                  cCol++;
        //                }

        //              }
        //            }
        //          }
        //        }
        //      }
        //      return true;
        //    }

        //    catch (Exception ex) { throw ex; }
        //  }

        //  private bool mapQuery ( DataTable qryResult, string qryID, string xlID, int rw, int clm, Boolean sheet )
        //  {
        //    Excel.Range rn;
        //    Entity theObject = new Entity ( ); ClsUtility.Init_Hashtable ( );
        //    try
        //    {
        //      if (qryResult.Rows.Count > 0)
        //      {
        //        DataTable theDt;
        //        theDt = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams
        //            , "SELECT xlsCell, xlsTitle FROM aa_XLMaps WHERE QryID= " + qryID + " AND xlCatID=" + xlID, ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //        DataTableReader dr = theDt.CreateDataReader ( );
        //        DataTableReader theDr;
        //        while (dr.Read ( ))
        //        {
        //          for (int i = 0; i < qryResult.Columns.Count; i++)
        //          {
        //            theDr = qryResult.CreateDataReader ( );
        //            while (theDr.Read ( ))
        //            {
        //              if (qryResult.Rows.Count == 1)
        //              {
        //                if (qryResult.Columns[i].ColumnName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                {
        //                  rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                  rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, "0" );
        //                  // rn.get_Offset(rw, clm).BorderAround(Type.Missing, Excel.XlBorderWeight.xlThin, Excel.XlColorIndex.xlColorIndexAutomatic, Type.Missing);
        //                  rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, theDr[i].ToString ( ) );
        //                  break;
        //                }
        //              }
        //              string fldName = "";
        //              if (theDr.FieldCount == 3)
        //              {
        //                if (theDr.GetName ( 0 ).ToLower ( ) == "gender" || theDr.GetName ( 1 ).ToLower ( ) == "gender" || theDr.GetName ( 2 ).ToLower ( ) == "gender")
        //                {
        //                  fldName = theDr["Gender"].ToString ( ) + theDr["AgeGroup"].ToString ( ) + "Total";
        //                  if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                  {
        //                    rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                    rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, 0 );                      
        //                    if (theDr["Total"].ToString ( ) != "")
        //                      rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, theDr["Total"].ToString ( ) );
        //                    break;
        //                  }
        //                }
        //                else if (theDr.GetName ( 0 ).ToLower ( ) == "regimen" || theDr.GetName ( 1 ).ToLower ( ) == "regimen" || theDr.GetName ( 2 ).ToLower ( ) == "regimen")
        //                {
        //                  fldName = theDr["Regimen"].ToString ( ) + theDr["AgeGroup"].ToString ( ) + "Total";
        //                  if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                  {
        //                    rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                    rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, 0 );
        //                    rn.get_Offset ( rw, clm ).BorderAround ( Type.Missing, Excel.XlBorderWeight.xlThin, Excel.XlColorIndex.xlColorIndexAutomatic, Type.Missing );
        //                    rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, theDr["Total"].ToString ( ) );
        //                    break;
        //                  }
        //                }
        //                else if (theDr.GetName ( 0 ).ToLower ( ) == "result" || theDr.GetName ( 1 ).ToLower ( ) == "result" || theDr.GetName ( 2 ).ToLower ( ) == "result")
        //                {
        //                  fldName = theDr["Indicator Description"].ToString ( );
        //                  if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                  {
        //                    rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                    rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, 0 );
        //                    rn.get_Offset ( rw, clm ).BorderAround ( Type.Missing, Excel.XlBorderWeight.xlThin, Excel.XlColorIndex.xlColorIndexAutomatic, Type.Missing );
        //                    rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, theDr["Result"].ToString ( ) );
        //                    break;
        //                  }
        //                }
        //              }
        //              else if (theDr.FieldCount == 4)
        //              {
        //                if (theDr.GetName ( 0 ).ToLower ( ) == "last status" || theDr.GetName ( 1 ).ToLower ( ) == "last status" || theDr.GetName ( 2 ).ToLower ( ) == "last status" || theDr.GetName ( 3 ).ToLower ( ) == "last status")
        //                {
        //                  fldName = theDr["Gender"].ToString ( ) + theDr["AgeGroup"].ToString ( ) + theDr["Last Status"].ToString ( );
        //                  if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                  {
        //                    rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                    rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, "0" );
        //                    rn.get_Offset ( rw, clm ).BorderAround ( Type.Missing, Excel.XlBorderWeight.xlThin, Excel.XlColorIndex.xlColorIndexAutomatic, Type.Missing );
        //                    rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, theDr["Total"].ToString ( ) );
        //                    break;
        //                  }
        //                }
        //                else
        //                {
        //                  fldName = theDr["Gender"].ToString ( ) + theDr["AgeGroup"].ToString ( ) + theDr["Indicator"].ToString ( );
        //                  if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                  {
        //                    rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                    rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, "0" );
        //                    rn.get_Offset ( rw, clm ).BorderAround ( Type.Missing, Excel.XlBorderWeight.xlThin, Excel.XlColorIndex.xlColorIndexAutomatic, Type.Missing );
        //                    rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, theDr["Total"].ToString ( ) );
        //                    break;
        //                  }
        //                }
        //              }
        //              else
        //              {
        //                fldName = theDr[0].ToString ( );
        //                if (theDr.GetName ( 0 ).Trim ( ).ToLower ( ) == "total")
        //                  fldName = theDr[1].ToString ( );

        //                if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                {
        //                  rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                  rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, "0" );
        //                  rn.get_Offset ( rw, clm ).BorderAround ( Type.Missing, Excel.XlBorderWeight.xlThin, Excel.XlColorIndex.xlColorIndexAutomatic, Type.Missing );
        //                  rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, theDr[1].ToString ( ) );
        //                  break;
        //                }

        //                else if (fldName.Trim ( ).ToLower ( ) + "total" == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                {
        //                  rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                  rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, "0" );
        //                  rn.get_Offset ( rw, clm ).set_Value ( m_objOpt, theDr[1].ToString ( ) );
        //                  break;
        //                }
        //              }                
        //            }
        //          }
        //        }
        //      }
        //      return true;
        //    }
        //    catch (Exception ex)
        //    {
        //      throw ex;
        //    }
        //  }

        //  private bool mapQuery ( DataTable qryResult, string qryID, string xlID )
        //  {
        //    Excel.Range rn;
        //    Entity theObject = new Entity ( ); ClsUtility.Init_Hashtable ( );
        //    try
        //    {
        //      if (qryResult.Rows.Count > 0)
        //      {
        //        DataTable theDt;
        //        theDt = (DataTable)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams
        //            , "SELECT xlsCell, xlsTitle, DHISElementID, CategoryOptionID FROM aa_XLMaps WHERE QryID= " + qryID + 
        //            " AND xlCatID=" + xlID, ClsUtility.ObjectEnum.DataTable, clsGbl.PMMSType );
        //        DataTableReader dr = theDt.CreateDataReader ( );
        //        DataTableReader theDr;
        //        while (dr.Read ( ))
        //        {
        //          for (int i = 0; i < qryResult.Columns.Count; i++)
        //          {

        //            int rowNum = 0;
        //            int colNum = 0;
        //            if (dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ) == "#linelist")
        //            {
        //              rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //              colNum = rn.Column;
        //              rowNum = rn.Row;
        //            }
        //            theDr = qryResult.CreateDataReader ( );
        //            while (theDr.Read ( ))
        //            {
        //              #region OtherElemets
        //              if (dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ) == "#linelist")
        //              {
        //                if (theDr[i].ToString ( ) != "")
        //                { oWs.Cells[rowNum, colNum + i] = theDr[i].ToString ( ); }

        //                rowNum += 1;

        //                continue;
        //              }

        //              if (qryResult.Rows.Count == 1 && theDr.GetName(0).ToLower() != "gender")
        //              {
        //                if (qryResult.Columns[i].ColumnName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                {
        //                  try
        //                  {
        //                    rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                    if (theDr[i].ToString ( ) != "")
        //                    { rn.Value2 = theDr[i].ToString ( ); }
        //                    try
        //                    {
        //                      addDHIS2Value ( dr["DHISElementID"].ToString ( ), dr["categoryOptionID"].ToString ( ), rn.Value2.ToString ( ) );
        //                    }
        //                    catch { }
        //                  }
        //                  catch (Exception ex)
        //                  {
        //                    if (theDr[i].ToString ( ) != "")
        //                      MessageBox.Show ( ex.Message );
        //                  }
        //                }
        //                break;
        //              }
        //              #endregion

        //              string fldName = "";
        //              if (theDr.FieldCount == 3)
        //              {
        //                if (theDr.GetName ( 0 ).ToLower ( ) == "gender" || theDr.GetName ( 1 ).ToLower ( ) == "gender" || theDr.GetName ( 2 ).ToLower ( ) == "gender")
        //                {
        //                  fldName = theDr["Gender"].ToString ( ) + theDr[1].ToString ( ) + "Total";
        //                  if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                  {
        //                    rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing ); rn.Value2 = 0;
        //                    rn.Value2 = theDr["Total"].ToString ( );
        //                    addDHIS2Value ( dr["DHISElementID"].ToString ( ), dr["categoryOptionID"].ToString ( ), rn.Value2.ToString ( ) );
        //                    break;
        //                  }
        //                }
        //                else if (theDr.GetName ( 0 ).ToLower ( ) == "regimen" || theDr.GetName ( 1 ).ToLower ( ) == "regimen" || theDr.GetName ( 2 ).ToLower ( ) == "regimen")
        //                {
        //                  fldName = theDr["Regimen"].ToString ( ).Trim ( ) + theDr["AgeGroup"].ToString ( ).Trim ( ) + "Total";
        //                  if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                  {
        //                    rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing ); rn.Value2 = 0;
        //                    rn.Value2 = theDr["Total"].ToString ( );
        //                    addDHIS2Value ( dr["DHISElementID"].ToString ( ), dr["categoryOptionID"].ToString ( ), rn.Value2.ToString ( ) );
        //                    break;
        //                  }
        //                }
        //                else if (theDr.GetName ( 0 ).ToLower ( ) == "result" || theDr.GetName ( 1 ).ToLower ( ) == "result" || theDr.GetName ( 2 ).ToLower ( ) == "result")
        //                {
        //                  fldName = theDr["Indicator Description"].ToString ( );
        //                  if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                  {
        //                    rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                    rn.Value2 = 0;
        //                    rn.BorderAround ( Type.Missing, Excel.XlBorderWeight.xlThin, Excel.XlColorIndex.xlColorIndexAutomatic, Type.Missing );
        //                    rn.Value2 = theDr["Result"].ToString ( );
        //                    addDHIS2Value ( dr["DHISElementID"].ToString ( ), dr["categoryOptionID"].ToString ( ), rn.Value2.ToString ( ) );
        //                    break;
        //                  }
        //                }
        //              }
        //              #region FieldCount=4
        //              else if (theDr.FieldCount == 4)
        //              {
        //                if (theDr.GetName ( 0 ).ToLower ( ) == "last status" || theDr.GetName ( 1 ).ToLower ( ) == "last status" 
        //                    || theDr.GetName ( 2 ).ToLower ( ) == "last status" || theDr.GetName ( 3 ).ToLower ( ) == "last status")
        //                {
        //                  fldName = theDr["Gender"].ToString ( ) + theDr["AgeGroup"].ToString ( ) + theDr["Last Status"].ToString ( );
        //                  if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                  {
        //                    rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                    rn.Value2 = 0;
        //                    rn.Value2 = theDr["Total"].ToString ( );
        //                    addDHIS2Value ( dr["DHISElementID"].ToString ( ), dr["categoryOptionID"].ToString ( ), rn.Value2.ToString ( ) );
        //                    break;
        //                  }
        //                }
        //                else
        //                {
        //                  //TODO: add code to take care of custom reports that have 4 columns
        //                  fldName = theDr["Gender"].ToString ( ) + theDr["AgeGroup"].ToString ( ) + theDr["Indicator"].ToString ( );
        //                  if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                  {
        //                    rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                    rn.Value2 = 0;
        //                    rn.Value2 = theDr["Total"].ToString ( );
        //                    addDHIS2Value ( dr["DHISElementID"].ToString ( ), dr["categoryOptionID"].ToString ( ), rn.Value2.ToString ( ) );
        //                    break;
        //                  }
        //                }
        //              }
        //              else //TODO: DONE Change this to accomodate other items that have total
        //              {
        //                fldName = theDr[0].ToString ( );

        //                if (theDr.GetName ( 0 ).Trim ( ).ToLower ( ) == "total")
        //                  fldName = theDr[1].ToString ( );


        //                if (fldName.Trim ( ).ToLower ( ) == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                {
        //                  rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                  rn.Value2 = 0;
        //                  rn.Value2 = theDr[1].ToString ( );
        //                  addDHIS2Value ( dr["DHISElementID"].ToString ( ), dr["categoryOptionID"].ToString ( ), rn.Value2.ToString ( ) );
        //                  break;

        //                }

        //                else if (fldName.Trim ( ).ToLower ( ) + "total" == dr["xlsTitle"].ToString ( ).Trim ( ).ToLower ( ))
        //                {
        //                  rn = oWs.get_Range ( dr["xlsCell"].ToString ( ), Type.Missing );
        //                  rn.Value2 = 0;
        //                  rn.Value2 = theDr["Total"].ToString ( );
        //                  addDHIS2Value ( dr["DHISElementID"].ToString ( ), dr["categoryOptionID"].ToString ( ), rn.Value2.ToString ( ) );
        //                  break;
        //                }
        //              }
        //              #endregion
        //            }
        //          }
        //        }

        //      }

        //      return true;
        //    }
        //    catch (Exception ex)
        //    {
        //      throw ex;
        //    }
        //  }

        //  private string SQLString ( string dfn )
        //  {
        //    foreach (DictionaryEntry hk in myParameters)
        //    {
        //      dfn = dfn.ToLower ( ).Replace ( hk.Key.ToString ( ).ToLower ( ).Trim ( ), "'" + hk.Value.ToString ( ) + "'" );
        //    }
        //    return dfn;
        //  }

        //  public string SQLString ( string dfn, string CCC, string dbSet )
        //  {
        //    if(serverType.ToLower() == "pgsql")
        //    {
        //        foreach (DictionaryEntry hk in myParameters)
        //        {
        //            try
        //            {
        //                ClsUtility.AddParameters(hk.Key.ToString().ToLower().Trim(), SqlDbType.Text, hk.Value.ToString());               
        //            }
        //            catch (Exception ex) { MessageBox.Show(ex.Message); }
        //        }
        //    }
        //    else {
        //    foreach (DictionaryEntry hk in myParameters)
        //    {
        //        try
        //        {
        //            if (dfn.Substring(0, 2).ToLower() != "pr")
        //            {
        //                string theKey = hk.Key.ToString().ToLower().Trim();
        //                string theValue = "'" + hk.Value.ToString() + "'";
        //                //dfn = dfn.Replace(hk.Key.ToString().ToLower().Trim(), "'" + hk.Value.ToString() + "'");
        //                dfn = dfn.Replace(theKey, theValue);
        //            }
        //            else
        //            {
        //                //dfn = dfn.Replace ( hk.Key.ToString ( ).ToLower ( ).Trim ( ), "" );          
        //                ClsUtility.AddParameters(hk.Key.ToString().ToLower().Trim(), SqlDbType.VarChar, hk.Value.ToString());
        //            }
        //        }
        //        catch (Exception ex) { MessageBox.Show(ex.Message); }
        //    }
        //    if (CCC != "")
        //      dfn = dfn.Replace ( "@ccc", "'" + CCC.Replace ( "'", "''" ) + "'" );
        //    if (dbSet != "")
        //      dfn = dfn.Replace ( "@lptf", "'" + dbSet.Replace ( "'", "''" ) + "'" );
        //    }
        //    return dfn;
        //  }

        //  public bool toExcel ( DataGridView dgv )
        //  {
        //    //bool mErrors;
        //    oExcel = new Excel.Application ( ); //setting the excel files
        //    oExcel.Visible = false; int iRow = 2;
        //    oBook = (Excel.Workbook)oExcel.Workbooks.Add ( xlTemplate );

        //    oWs = (Excel.Worksheet)oBook.Worksheets[1];
        //    ((Microsoft.Office.Interop.Excel._Worksheet)oWs).Activate ( );
        //    //oWs.Activate();

        //    try
        //    {

        //      for (int j = 0; j < dgv.Columns.Count; j++)
        //      { oWs.Cells[1, j + 1] = dgv.Columns[j].Name; }

        //      for (int rowNo = 0; rowNo < dgv.Rows.Count; rowNo++)
        //      {
        //        for (int colNo = 0; colNo < dgv.Columns.Count; colNo++)
        //        { oWs.Cells[iRow, colNo + 1] = dgv.Rows[rowNo].Cells[colNo].Value.ToString ( ); }
        //        iRow++;
        //      }

        //    }
        //    catch
        //    { return false; }

        //    clsGbl.IQDirection = "";

        //    oBook.Close ( true, Type.Missing, Type.Missing );
        //    oExcel.Quit ( ); oExcel = null;
        //    return true;
        //  }

        //  private DataTable DHISDT;

        //  private void resetDHIS2DataTable ( )
        //  {
        //    DHISDT = new DataTable ( "DHIS2" );
        //    DHISDT.Columns.Add ( "DHISElementID", typeof ( String ) );
        //    DHISDT.Columns.Add ( "categoryOptionID", typeof ( String ) );
        //    DHISDT.Columns.Add ( "value", typeof ( String ) );

        //  }

        //  private void addDHIS2Value ( String DHISElementID, String categoryOptionID, String value )
        //  {
        //    try
        //    {
        //      if (DHISElementID == "") return;
        //      //TODO VY add code that adds this values to a dataTable and out put them(for now to XML)
        //      var elementExists = DHISDT.Select ( "DHISElementID  = '" + DHISElementID + "' AND categoryOptionID ='" + categoryOptionID + "'" );

        //      if (elementExists.Length != 0) return;
        //      if (value.Trim ( ) == "") value = "0";
        //      DataRow row = DHISDT.NewRow ( );
        //      row["DHISElementID"] = DHISElementID;
        //      row["categoryOptionID"] = categoryOptionID;
        //      row["value"] = value;
        //      DHISDT.Rows.Add ( row );
        //    }
        //    catch
        //    {
        //      //Write to some log file
        //    }
        //  }

        //  private XmlDocument createDHIS2XMLFile ( )
        //  {
        //    XmlTextWriter xtw = new XmlTextWriter ( "C:\\Cohort\\DHIS2XML.xml", System.Text.Encoding.UTF8 );
        //    xtw.WriteStartDocument ( true );
        //    xtw.Formatting = Formatting.Indented;
        //    xtw.Indentation = 2;

        //    xtw.WriteStartElement ( "dataValueSet" );
        //    //  xtw.WriteAttributeString("orgUnit", "IgrMpQRUx5y");//Kericho district hospital
        //    // xtw.WriteAttributeString("period", "201210");
        //    // xtw.WriteAttributeString("completeDate", DateTime.Now.Date.ToString("yyyy-MM-dd"));
        //    // xtw.WriteAttributeString("dataSet", "UpS2bTVcClZ");
        //    xtw.WriteAttributeString ( "xmlns", "http://dhis2.org/schema/dxf/2.0" );





        //    DataTableReader dtr = new DataTableReader ( DHISDT );
        //    while (dtr.Read ( ))
        //    {
        //      xtw.WriteStartElement ( "dataValue" );
        //      xtw.WriteAttributeString ( "value", dtr["value"].ToString ( ) );
        //      xtw.WriteAttributeString ( "orgUnit", DHISCode );//Kericho district hospital
        //      xtw.WriteAttributeString ( "period", getPeriod ( ) );
        //      xtw.WriteAttributeString ( "categoryOptionCombo", dtr["categoryOptionID"].ToString ( ) );
        //      xtw.WriteAttributeString ( "dataElement", dtr["DHISElementID"].ToString ( ) );


        //      xtw.WriteEndElement ( );

        //    }
        //    xtw.WriteEndElement ( );
        //    xtw.WriteEndDocument ( );
        //    xtw.Close ( );

        //    XmlDocument xld = new XmlDocument ( );
        //    xld.Load ( "C:\\Cohort\\DHIS2XML.xml" );
        //    return xld;
        //  }

        //  private string getPeriod ( )
        //  {
        //    String period = "";

        //    switch (clsGbl.periodType)
        //    {

        //      case "Monthly":
        //        string month = StartDateDHIS.Month.ToString ( ).PadLeft ( 2, '0' );
        //        string year = StartDateDHIS.Year.ToString ( );
        //        period = year + month;
        //        break;

        //      case "Quarterly":
        //        //TODO VY add code for quterly format

        //        break;


        //      case "Custom":
        //        //TODO VY add code for custom format

        //        break;
        //    }
        //    return period;

        //  }

        //  public static XmlDocument pstXML ( string strURL, XmlDocument xmlDocument, string credents )
        //  {

        //    XmlDocument XMLResponse = null;
        //    HttpWebRequest objHttpWebRequest;

        //    HttpWebResponse objHttpWebResponse = null;
        //    Stream objRequestStream = null;

        //    byte[] authBytes = Encoding.UTF8.GetBytes ( credents.ToCharArray ( ) );

        //    objHttpWebRequest = (HttpWebRequest)WebRequest.Create ( strURL );
        //    try
        //    {
        //      byte[] bytes;
        //      bytes = ASCIIEncoding.ASCII.GetBytes ( xmlDocument.InnerXml );

        //      objHttpWebRequest.Headers["Authorization"] = "Basic " + Convert.ToBase64String ( authBytes );
        //      objHttpWebRequest.Method = "POST";

        //      objHttpWebRequest.Timeout = 100000;
        //      objHttpWebRequest.ContentLength = bytes.Length;
        //      objHttpWebRequest.ContentType = "application/xml";

        //      objRequestStream = objHttpWebRequest.GetRequestStream ( );
        //      objRequestStream.Write ( bytes, 0, bytes.Length );

        //      objRequestStream.Close ( );
        //      objHttpWebResponse = (HttpWebResponse)objHttpWebRequest.GetResponse ( );

        //      if (objHttpWebResponse.StatusCode == HttpStatusCode.OK)
        //      {
        //        MessageBox.Show ( "Successfully posted to DHIS" );
        //      }
        //      objHttpWebResponse.Close ( );
        //    }
        //    catch (WebException we)
        //    {
        //      MessageBox.Show ( we.Message, "Post to DHIS", MessageBoxButtons.OK, MessageBoxIcon.Error );
        //    }
        //    catch (Exception ex)
        //    { MessageBox.Show ( ex.Message, "Post to DHIS", MessageBoxButtons.OK, MessageBoxIcon.Error ); }

        //    finally
        //    {
        //      if (objRequestStream != null)
        //        objRequestStream.Close ( );
        //      if (objHttpWebResponse != null)
        //        objHttpWebResponse.Close ( );
        //      objRequestStream = null;
        //      objHttpWebResponse = null;
        //      objHttpWebRequest = null;
        //    }
        //    return XMLResponse;
        //  }

        //  public void PatientSummaryBulk ( List<string> patientIDs, ProgressBar pb )
        //  {
        //    string patientID = string.Empty;
        //    double patientAge = 0;
        //    int patientPK = 0;
        //    Entity en = new Entity ( );

        //    bPatSummaryBulkReport = true;

        //    for (int i = 0; i < patientIDs.Count; i++)
        //    {
        //      try
        //      {
        //        DataRow dr = (DataRow)en.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT Top 1 PatientPK, AgeLastVisit,PatientID FROM tmp_PatientMaster Where PatientID Like '%" + patientIDs[i] + "'", ClsUtility.ObjectEnum.DataRow, "mssql" );

        //        patientAge = Convert.ToDouble ( dr[1].ToString ( ) );
        //        patientPK = Convert.ToInt32 ( dr[0].ToString ( ) );
        //        patientID = dr[2].ToString ( );

        //        DataRow theDr = null;
        //        xlWorkSheet = "PatientSummary";
        //        theObject = new Entity ( );

        //        Hashtable pmARQueries = new Hashtable ( );
        //        pmARQueries.Add ( "@PatientPk", patientPK );

        //        myParameters = pmARQueries;

        //        if (patientAge >= 15)
        //        {
        //          xlTemplate = clsGbl.tmpFolder + "PatientSummary_Adult Template.xls";
        //          theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'AdultPatientSummary'", ClsUtility.ObjectEnum.DataRow, "mssql" );
        //        }
        //        else
        //        {
        //          xlTemplate = clsGbl.tmpFolder + "PatientSummary_Paed Template.xls";
        //          theDr = (DataRow)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, "SELECT CatID FROM aa_Category WHERE Category = 'PaedPatientSummary'", ClsUtility.ObjectEnum.DataRow, "mssql" );
        //        }

        //        xlFileName = clsGbl.tmpFolder + "Patient Summary\\Patient Summary - " + patientID + ".xls";

        //        int catID = Convert.ToInt32 ( theDr["CatID"].ToString ( ) );

        //        getQueries ( catID, "all", null, null, null, false, null );

        //        //Update progress bar
        //        double div = Convert.ToDouble ( i + 1 ) / Convert.ToDouble ( patientIDs.Count );
        //        double progress = div * 100;
        //        UpdateProgress ( (int)progress, pb );
        //      }
        //      catch
        //      {

        //      }
        //    }

        //    bPatSummaryBulkReport = false;

        //    MessageBox.Show ( @"The generation of multiple patient summaries has completed. Pick them from C:\Cohort\Formulas\Patient Summary", "IQTools", MessageBoxButtons.OK, MessageBoxIcon.Information );
        //}
    }
}