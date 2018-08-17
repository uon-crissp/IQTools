using System;
using System.Collections;
using OfficeOpenXml;
using System.IO;
using System.Windows.Forms;
using DataLayer;
using System.Data;
using System.Linq;


namespace BusinessLayer
{
    public class ReportsManager
    {
        string iqtoolsConnString = Entity.getconnString(clsGbl.xmlPath);
        string serverType = Entity.getServerType(clsGbl.xmlPath);

        public void runReport(Hashtable reportParameters, DataTable satellites, bool bySatellite, bool lineLists)
        {
            //MessageBox.Show(ReportSaveName(ClsUtility.theParams));
            string reportName = reportParameters["ReportName"].ToString();
            //string xlTemplate = clsGbl.tmpFolder + reportParameters["ExcelTemplateName"].ToString();
            string xlTemplate = "Templates\\" + reportParameters["ExcelTemplateName"].ToString();  
            string xlSheet = reportParameters["ExcelWorksheetName"].ToString();
            string groupName = reportParameters["GroupName"].ToString();
            Entity en = new Entity();
            string sp = "pr_GetReportData_IQTools";

            string fldName = String.Empty;

            Hashtable rName = new Hashtable();
            rName.Add(1, "@ReportName");
            rName.Add(2, "Varchar");
            rName.Add(3, reportName);

            DataSet ds = (DataSet)en.ReturnObject(iqtoolsConnString, rName
                , sp, ClsUtility.ObjectEnum.DataSet, serverType);
            int numberOfQueries = ds.Tables[1].Rows.Count;
            DataTableReader queries = ds.Tables[1].CreateDataReader();
            DataTable XLMapping = ds.Tables[2];
            DataTable ReportLineLists = ds.Tables[4];
            //string newF = clsGbl.tmpFolder + reportName + ".xlsx";
            //string newF = "IQTools Reports\\" + reportName + DateTime.Now.ToShortDateString() + " - " + DateTime.Now.ToShortTimeString() + ".xlsx";
            string myDocsPath = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            string newF = myDocsPath + "\\IQTools Reports\\" + reportName + "\\" + clsGbl.loggedInUser.FacilityName + " - " + reportName + " - " + ReportSaveName(ClsUtility.theParams) + ".xlsx";
            //+ DateTime.Now.ToShortDateString() + " - " + DateTime.Now.ToShortTimeString() + ".xlsx";
            //MessageBox.Show(newF);
            //newF = newF.Replace("/", "-").Replace(":", "-");
            DataRow r = ds.Tables[0].Rows[0];
            string password = r["Password"].ToString();
            
            try
            {
                
                if (File.Exists(newF))
                    File.Delete(newF);

                var xl = new FileInfo(xlTemplate);
                var newFile = new FileInfo(newF);
                newFile.Directory.Create();

                using (var package = new ExcelPackage(newFile, xl))
                {
                    ExcelWorksheet ews = package.Workbook.Worksheets[xlSheet];
                    ExcelWorksheet blank = package.Workbook.Worksheets.Add("Blank", ews);
                    DataTable reportErrors = new DataTable("Errors");
                    reportErrors.Columns.Add("QUERY NAME");
                    reportErrors.Columns.Add("ERROR MESSAGE");
                    while (queries.Read())
                    {
                        try
                        {
                            DataTable queryResults = executeQuery(queries["qryDefinition"].ToString().Trim(), string.Empty);
                            DataTableReader queryResultsReader = queryResults.CreateDataReader();
                            XLMapping.DefaultView.RowFilter = "qryID = " + queries["qryID"].ToString();
                            DataTable mapping = XLMapping.DefaultView.ToTable();
                            mapQueryResults(queryResults, mapping, ews);
                        }
                        catch (Exception ex)
                        {
                            DataRow newError = reportErrors.NewRow();
                            newError["QUERY NAME"] = queries["qryName"].ToString();
                            newError["ERROR MESSAGE"] = ex.Message;
                            reportErrors.Rows.Add(newError);
                        }
                    }
                    if (bySatellite)
                    {
                        DataTableReader sdr = satellites.CreateDataReader();
                        while (sdr.Read())
                        {
                            string newWorksheet = sdr["FacilityName"].ToString();
                            ExcelWorksheet newWS = package.Workbook.Worksheets.Add(newWorksheet, blank);
                            newWS.TabColor = System.Drawing.Color.Yellow;
                            queries = ds.Tables[1].CreateDataReader();
                            while (queries.Read())
                            {
                                try
                                {
                                    DataTable queryResults = executeQuery(queries["qryDefinition"].ToString().Trim(), newWorksheet);
                                    XLMapping.DefaultView.RowFilter = "qryID = " + queries["qryID"].ToString();
                                    DataTable mapping = XLMapping.DefaultView.ToTable();
                                    mapQueryResults(queryResults, mapping, newWS);
                                }
                                catch (Exception ex)
                                {
                                    DataRow newError = reportErrors.NewRow();
                                    newError["QUERY NAME"] = queries["qryName"].ToString();
                                    newError["ERROR MESSAGE"] = ex.Message;
                                    reportErrors.Rows.Add(newError);
                                }
                            }
                            if (password.Trim() != string.Empty)
                            {
                                newWS.Protection.IsProtected = true;
                                newWS.Protection.SetPassword(ClsUtility.Decrypt(password));
                            }
                        }
                    }
                    if (lineLists)
                    {
                        MapReportLineList(ReportLineLists, package);
                    }
                    mapErrors(reportErrors, package);
                    package.Workbook.Worksheets.Delete(blank);
                    //package.SaveAs(newFile);
                    if (password.Trim() != string.Empty)
                    {
                        ews.Protection.IsProtected = true;
                        ews.Protection.SetPassword(ClsUtility.Decrypt(password));
                    }
                    package.Save();
                    
                    package.Dispose();
                }
                System.Diagnostics.Process.Start(newF);
            }
            catch (Exception ex)
            { MessageBox.Show(ex.Message); }
        }
        
        private void mapLineList(DataTable queryOutput, string startCell, ExcelWorksheet ws, bool printHeaders)
        {
            ws.Cells[startCell].LoadFromDataTable(queryOutput, printHeaders);
        }

        private void mapErrors(DataTable reportErrors, ExcelPackage pk)
        {
            if (reportErrors.Rows.Count >= 1)
            {
                DataView view = new DataView(reportErrors);
                DataTable distinctErrors = view.ToTable(true, "QUERY NAME", "ERROR MESSAGE");

                ExcelWorksheet errorsWS = pk.Workbook.Worksheets.Add("Errors");
                errorsWS.Cells["A1"].LoadFromDataTable(distinctErrors, true, OfficeOpenXml.Table.TableStyles.Medium2);
                errorsWS.TabColor = System.Drawing.Color.Red;
                errorsWS.Cells.AutoFitColumns();
            }
            
        }
      
        private DataTable executeQuery(string sql, string satellite)
        {
            Entity en = new Entity();
            DataTable queryResults = new DataTable();
            if (satellite == string.Empty)
            {
                queryResults = (DataTable)en.ReturnObject(iqtoolsConnString
                                , ClsUtility.theParams, sql.Trim()
                                , ClsUtility.ObjectEnum.DataTable
                                , serverType);
            }
            else
            {
                string modifiedQuery = string.Empty;
                modifiedQuery = sql.ToLower().Replace("where", "where satellitename = '" + satellite + "' and");
                queryResults = (DataTable)en.ReturnObject(iqtoolsConnString
                                        , ClsUtility.theParams, modifiedQuery.Trim()
                                        , ClsUtility.ObjectEnum.DataTable
                                        , serverType);
            }
            return queryResults;
        }

        private void mapQueryResults(DataTable queryResults, DataTable XLMapping, ExcelWorksheet XLWS)
        {
            DataTableReader queryResultsReader = queryResults.CreateDataReader();
            string fldName = string.Empty;

            while (queryResultsReader.Read())
            {
                DataTableReader mappingReader = XLMapping.CreateDataReader();
                fldName = String.Empty;
                for (int i = 0; i < queryResults.Columns.Count - 1; i++)
                {
                    fldName += queryResultsReader[i].ToString();
                }
                fldName += "Total";
                if (queryResultsReader.GetName(queryResults.Columns.Count - 1).ToLower() == "total")
                {
                    while (mappingReader.Read())
                    {
                        string xlsCell = mappingReader["xlsCell"].ToString();
                        string xlsTitle = mappingReader["xlsTitle"].ToString();
                        if (xlsTitle.ToLower() == "#linelist")
                        {
                            mapLineList(queryResults, xlsCell, XLWS, false);
                        }
                        else if (xlsTitle.ToLower() == fldName.ToLower())
                        {
                            XLWS.Cells[xlsCell].Value
                                = Convert.ToInt32(queryResultsReader["Total"].ToString());
                            XLWS.Cells[xlsCell].Style.Numberformat.Format = "#,##0";
                        }
                    }
                }
                else if (queryResults.Rows.Count == 1)
                {
                    while (mappingReader.Read())
                    {
                        for (int i = 0; i < queryResults.Columns.Count; i++)
                        {
                            string xlsCell = mappingReader["xlsCell"].ToString();
                            string xlsTitle = mappingReader["xlsTitle"].ToString();
                            if (xlsTitle.ToLower() == "#linelist")
                            {
                                mapLineList(queryResults, xlsCell, XLWS, false);
                            }
                            fldName = queryResultsReader.GetName(i);
                            if (xlsTitle.ToLower() == fldName.ToLower())
                            {
                                int result;
                                if (int.TryParse(queryResultsReader[i].ToString(), out result))
                                {
                                    XLWS.Cells[xlsCell].Value = result;
                                    //XLWS.Cells[xlsCell].Style.Numberformat.Format = "#,##0";
                                }
                                else
                                {
                                    XLWS.Cells[xlsCell].Value = queryResultsReader[i].ToString();
                                }
                            }
                        }
                    }
                }
                else
                {
                    while (mappingReader.Read())
                    {
                        string xlsCell = mappingReader["xlsCell"].ToString();
                        string xlsTitle = mappingReader["xlsTitle"].ToString();
                        if (xlsTitle.ToLower() == "#linelist")
                        {
                            mapLineList(queryResults, xlsCell, XLWS, false);
                        }
                        if (xlsTitle.ToLower() == "#linelist_")
                        {
                            mapLineList(queryResults, xlsCell, XLWS, true);
                        }
                    }
                }
            }

        }

        private void MapReportLineList(DataTable d, ExcelPackage pk)
        {
            try
            {
                DataTableReader linelists = d.CreateDataReader();
                while (linelists.Read())
                {
                    string sql = linelists[0].ToString();
                    string worksheetName = linelists[1].ToString();
                    DataTable queryResults = executeQuery(sql, string.Empty);

                    ExcelWorksheet linelistWS = pk.Workbook.Worksheets.Add(worksheetName);
                    //Check if queryResults has any rows
                    if (queryResults.Rows.Count > 0)
                    {
                        linelistWS.Cells["A1"].LoadFromDataTable(queryResults, true, OfficeOpenXml.Table.TableStyles.Medium2);

                        var rowCount = queryResults.Rows.Count;
                        //Format Date Columns
                        var dateColumns = from DataColumn dcol in queryResults.Columns
                                          where dcol.DataType == typeof(DateTime) || dcol.ColumnName.Contains("Date")
                                          select dcol.Ordinal + 1;

                        foreach (var dc in dateColumns)
                        {
                            linelistWS.Cells[2, dc, rowCount + 1, dc].Style.Numberformat.Format = "dd/mm/yyyy";
                        }
                        //
                        linelistWS.TabColor = System.Drawing.Color.PowderBlue;
                        linelistWS.Cells.AutoFitColumns();
                    }
                    else
                    {
                        linelistWS.TabColor = System.Drawing.Color.Yellow;
                    }      
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private string ReportSaveName(Hashtable ht)
        {
            string reportSaveName = string.Empty;

            if(ht[4].ToString().ToLower() == "@todate")
            {
                reportSaveName += ht[6].ToString();
            }
            else if(ht[1].ToString().ToLower() == "@todate")
            {
                reportSaveName += ht[3].ToString();
            }

            //foreach (DictionaryEntry de in ht)
            //{
            //    if(de.Key.ToString().ToLower() == "@todate")
            //    {
            //        reportSaveName += de.Value.ToString();
            //    }
            //}
            return reportSaveName;
        }        
    }
}
