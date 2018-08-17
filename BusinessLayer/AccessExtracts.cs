using ADOX;
using System;
using System.Text;
using System.Data;
using System.Data.OleDb;
using System.Collections;
using System.Windows.Forms;

namespace BusinessLayer
{
    public class AccessExtracts
    {
        Catalog AccDb;
        private DateTime getRptEnd(Hashtable x)
        {
            string periodEnd = "";
            foreach (DictionaryEntry hk in x)
            {
                if (hk.Key.ToString().ToLower().Trim() == "@todate")
                {
                    periodEnd = hk.Value.ToString();
                    break;
                }
            }
            if (periodEnd == "")
                return DateTime.Today;
            else
                return Convert.ToDateTime(periodEnd);

        }

        public string AcessDB(Hashtable pmCDCQueries)
        {
            string connString = "";
            connString += "Provider=Microsoft.Jet.OLEDB.4.0;";
            connString += "Data Source=" + clsGbl.tmpFolder + "CDC Databases\\CDC Lwak - " + getRptEnd(pmCDCQueries).Year + " " + getRptEnd(pmCDCQueries).Month + " " + getRptEnd(pmCDCQueries).Day + ".mdb" + ";";
            string DBPath = "";
            try
            {
                DBPath = clsGbl.tmpFolder + "CDC Databases\\CDC Lwak - " + getRptEnd(pmCDCQueries).Year + " " + getRptEnd(pmCDCQueries).Month + " " + getRptEnd(pmCDCQueries).Day + ".mdb";
                try
                {
                    if (System.IO.File.Exists(DBPath))
                        System.IO.File.Delete(DBPath);
                }
                catch { return ""; }
                finally
                {
                    try
                    {
                        AccDb = new Catalog();
                        AccDb.Create(connString);
                    }
                    catch { }
                }
                return connString;
            }
            catch { return ""; }
        }


        private DataTypeEnum GetDataType(string dataType)
        {
            DataTypeEnum DTTemp = new DataTypeEnum();

            switch (dataType)
            {
                case ("System.Decimal"):
                    DTTemp = DataTypeEnum.adDouble;
                    break;
                case ("System.String"):
                    DTTemp = DataTypeEnum.adVarWChar;
                    break;
                case ("System.Int16"):
                    DTTemp = DataTypeEnum.adSmallInt;
                    break;
                case ("System.Int32"):
                    DTTemp = DataTypeEnum.adInteger;
                    break;
                case ("System.Int64"):
                    DTTemp = DataTypeEnum.adBigInt;
                    break;
                case ("System.DateTime"):
                    DTTemp = DataTypeEnum.adDate;
                    break;
                case ("System.Double"):
                    DTTemp = DataTypeEnum.adDouble;
                    break;
                case ("System.Single"):
                    DTTemp = DataTypeEnum.adSingle;
                    break;
                default:
                    DTTemp = DataTypeEnum.adVariant;
                    break;
            }
            return DTTemp;
        }

        private string crtTable(string tblName, DataTable theDt)
        {
            Cursor.Current = Cursors.WaitCursor;
           //  Table tmp = new Table();
           // tmp.Name = tblName;

            string tmpFields = "";
            try
            {
                foreach (DataColumn dc in theDt.Columns)
                {
                    //Create columns from datatable column schema
                    //tmp.Columns.Append(dc.ColumnName, GetDataType(dc.DataType.ToString()), 100);
                    tmpFields += "[" + dc.ColumnName + "]";
                    if (dc.ColumnName != theDt.Columns[theDt.Columns.Count - 1].ColumnName)
                        tmpFields += ", ";
                }
                //AccDb.Tables.Append(tmp);
                return tmpFields;
            }
            catch { return ""; }
        }

        public string CreateTable(DataTable Dt, string tblName)
        {
            return crtTable(tblName, Dt);
        }

        public string  DetermineCTCVersion(string TableName,OleDbConnection Dbconnection)
        {
        // Variable to return that defines if the table exists or not.
       
          string ctcVersion =  null;
          string tableVersion = "tblPatients";  // purposely to test export for analysis
          string columnName = "FirstName";
          using (Dbconnection)
          {
            try {
             if (Dbconnection.State.ToString() == "closed")
                Dbconnection.Open ( );

               // Get the datatable information
              DataTable dt = Dbconnection.GetSchema ( "Tables" );
              var schema = Dbconnection.GetSchema("COLUMNS"); 
               var col = schema.Select("TABLE_NAME='" + tableVersion + 
                   "' AND COLUMN_NAME='" + columnName + "'");

               if (col.Length > 0)
               {
                 foreach (DataRow row in dt.Rows)
                 {
                   if (row.ItemArray[2].ToString ( ).ToLower ( ) == TableName.ToLower())
                   {
                     switch (TableName.ToLower ( ))
                     {
                       case "tblexposedinfants":
                         ctcVersion = "7.2";
                         break;
                         default:
                         ctcVersion = "6.0";
                         break;
                     }
                     break;
                   }
                 }
               }
               else
               {
                 foreach (DataRow row in dt.Rows)
                 {
                   if (row.ItemArray[2].ToString ( ).ToLower ( ) == TableName)
                   {
                     switch (TableName.ToLower ( ))
                     {
                       case "tblexposedinfants":
                         ctcVersion = "7.2efa";
                         break;
                       default:
                         ctcVersion = "6.0efa";
                         break;
                     }
                     break;
                   }
                 }
               }
            } catch
          {
          
          }
        }
         
          return ctcVersion;

        }

    }
}
