using System;
using System.Data;
using System.Data.SqlClient; 
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Globalization;


namespace BusinessLayer
{
    public class clsGbl
    {

        // Main configuration variables
        public static string DBSecurity = "'ttwbvXWpqb5WOLfLrBgisw=='";

        // TODO Change this to location where Users Group has modify rights by default

        //public static string xmlPath = System.Windows.Forms.Application.StartupPath + "\\Service.config";
        public static string xmlPath = "C:\\Cohort\\Service.config";
        public static string IQDbase = "";
        public static bool connTest = false;
        public static string StrComparisons = "";
        public static string PMMSType = "";
        public static string IQDate = "";
        public static string DBState = "";
        public static string PMMS = "";
        public static string ReportPassword = "Futur3s";
        public static string IQToolsVersion = "Default";
        public static string IQCareVersion = "";
        public static string EmrVersion = "";
        public static string EMRIPAddress = "";

        //TODO VY Done 2013/07/16 flags showing where the report should be outputed. and other DHIS varriables
        public static bool sendToDHIS = false;
        //public static bool openInExcel = true;
        public static string periodType = "";

        // user security variables
        public static string currGroup = "";
        public static string currUser = "";
        public static string currPass = "";

        // query specific variables
        public static string qryType = "";
        public static string currQuery = "";
        public static string currCategory = "";
        public static Hashtable mrgParams = null;
        public static Hashtable mrgQueries = null;


        // form navigation variables
        public static string IQDirection = "";
        public static string tmpNavigation = "";
        public static string currServer = "";
        public static string currData = "";
        public static string DBVersion = "";
        public static string ToUnPack = "";
        public static int progress = 0;
        // Excel reporting variables
        public static string tmpFolder = "C:\\Cohort\\Formulas\\";
        public static string tblRefresh = "";
        public static string locType = "";
        
        // Globalization

        //public static CultureInfoDisplayItem cidi = null;

        //KKirui List of PatientIDS - for Bulk Patient summary generation
        public static List<string> PatientIDs = new List<string>();

        //EMR user
        public static BusinessLayer.EMRUser loggedInUser = new BusinessLayer.EMRUser();
        public static bool SettingsValid = false;

        //EMR PatientIS
        public static string EMRPatientPK = "-1";

        //Queries

        public static DataTable Queries;

        //WebServices

        public static string RemoteWebServiceURL = "";
    }
}
