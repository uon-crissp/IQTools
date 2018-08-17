using DataLayer;

namespace BusinessLayer
{
    public class ErrorLogHelper
    {
        Entity en = new Entity();
        int i = 0;

        public void LogError(string message, string application, string serverType)
        {
            ClsUtility.Init_Hashtable();
            if (serverType.ToLower() == "mysql")
            {
                ClsUtility.AddParameters("ErrorMessage", System.Data.SqlDbType.Text, message);
                ClsUtility.AddParameters("Application", System.Data.SqlDbType.Text, application);
            }
            else
            { 
                ClsUtility.AddParameters("@Message", System.Data.SqlDbType.Text, message);
                ClsUtility.AddParameters("@Application", System.Data.SqlDbType.Text, application);            
            }
            try
            {
                //i = (int)en.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, "pr_ErrorLogger_IQTools", ClsUtility.ObjectEnum.ExecuteNonQuery, serverType);
            }
            catch { //Unable to Log 
            }
            
        }
    }
}
