using System;
using System.Collections.Generic;
using System.Text;
using System.Data.OleDb;
using System.IO;
using System.Xml.Serialization;
using System.Security.Cryptography;

namespace IQTools.Assets
{
    /// <summary>
    /// Summary description for HexEncoding.
    /// </summary>
    public class HexEncoding
    {
        public HexEncoding() { }

        public static int GetByteCount(string hexString)
        {
            int numHexChars = 0;
            char c;
            // remove all none A-F, 0-9, characters
            for (int i = 0; i < hexString.Length; i++)
            {
                c = hexString[i];
                if (IsHexDigit(c))
                    numHexChars++;
            }
            // if odd number of characters, discard last character
            if (numHexChars % 2 != 0)
            {
                numHexChars--;
            }
            return numHexChars / 2; // 2 characters per byte
        }


        /// <summary>
        /// Creates a byte array from the hexadecimal string. Each two characters are combined
        /// to create one byte. First two hexadecimal characters become first byte in returned array.
        /// Non-hexadecimal characters are ignored. 
        /// </summary>
        /// <param name="hexString">string to convert to byte array</param>
        /// <param name="discarded">number of characters in string ignored</param>
        /// <returns>byte array, in the same left-to-right order as the hexString</returns>
        public static byte[] GetBytes(string hexString, out int discarded)
        {
            discarded = 0;
            string newString = "";
            char c;
            // remove all none A-F, 0-9, characters
            for (int i = 0; i < hexString.Length; i++)
            {
                c = hexString[i];
                if (IsHexDigit(c))
                    newString += c;
                else
                    discarded++;
            }
            // if odd number of characters, discard last character
            if (newString.Length % 2 != 0)
            {
                discarded++;
                newString = newString.Substring(0, newString.Length - 1);
            }

            int byteLength = newString.Length / 2;
            byte[] bytes = new byte[byteLength];
            string hex;
            int j = 0;
            for (int i = 0; i < bytes.Length; i++)
            {
                hex = new String(new Char[] { newString[j], newString[j + 1] });
                bytes[i] = HexToByte(hex);
                j = j + 2;
            }
            return bytes;
        }

        public static string ToString(byte[] bytes)
        {
            string hexString = "";
            for (int i = 0; i < bytes.Length; i++)
            {
                hexString += bytes[i].ToString("X2");
            }
            return hexString;
        }

        /// <summary>
        /// Determines if given string is in proper hexadecimal string format
        /// </summary>
        /// <param name="hexString"></param>
        /// <returns></returns>
        public static bool InHexFormat(string hexString)
        {
            bool hexFormat = true;

            foreach (char digit in hexString)
            {
                if (!IsHexDigit(digit))
                {
                    hexFormat = false;
                    break;
                }
            }
            return hexFormat;
        }

        /// <summary>
        /// Returns true is c is a hexadecimal digit (A-F, a-f, 0-9)
        /// </summary>
        /// <param name="c">Character to test</param>
        /// <returns>true if hex digit, false if not</returns>
        public static bool IsHexDigit(Char c)
        {
            int numChar;
            int numA = Convert.ToInt32('A');
            int num1 = Convert.ToInt32('0');
            c = Char.ToUpper(c);
            numChar = Convert.ToInt32(c);
            if (numChar >= numA && numChar < (numA + 6))
                return true;
            if (numChar >= num1 && numChar < (num1 + 10))
                return true;
            return false;
        }

        /// <summary>
        /// Converts 1 or 2 character string into equivalant byte value
        /// </summary>
        /// <param name="hex">1 or 2 character string</param>
        /// <returns>byte</returns>
        private static byte HexToByte(string hex)
        {
            if (hex.Length > 2 || hex.Length <= 0)
                throw new ArgumentException("hex must be 1 or 2 characters in length");
            byte newByte = byte.Parse(hex, System.Globalization.NumberStyles.HexNumber);
            return newByte;
        }
    }

    /// <summary>
    /// CheckSum class
    /// </summary>
    public class CheckSum
    {
        private string m_CheckSum;

        /// <summary>
        /// Readonly
        /// </summary>
        [XmlElement(ElementName = "CheckSum")]
        public string Value
        {
            get {return m_CheckSum ;}
        }

        public CheckSum() { }

        public CheckSum(string FileName)
        {
            m_CheckSum = CreateHexCheckSum(FileName);
        }

        public bool CompareCheckSum(string CheckSum)
        {
            return (CheckSum == m_CheckSum);
        }

        public static bool CompareCheckSum(string SourceCheckSum,string TargetCheckSum)
        {
            return (SourceCheckSum == TargetCheckSum);
        }


        /// <summary>
        /// Please not that the modified date will be used in creating
        /// a checksum as the individual MDB files often a in use
        /// by another process (Jet Engine)
        /// </summary>
        /// <param name="FileName"></param>
        /// <returns></returns>
        public static string CreateHexCheckSum(string FileName)
        {
            byte[] retVal = null;
            FileInfo fi = new FileInfo(FileName);
            DateTime modifieddate  =fi.LastWriteTime;
            long moddate = modifieddate.Ticks;
            MD5 md5 = new MD5CryptoServiceProvider();
            retVal = BitConverter.GetBytes(moddate);
            retVal = md5.ComputeHash(retVal);
            return HexEncoding.ToString(retVal);
        }

        public static string CreateCheckSum(string FileName)
        {
            return CheckSum.CreateHexCheckSum(FileName);
        }

        //public static string CreateSHACheckSum(string FileName)
        //{
        //    using (FileStream fs = File.OpenRead(FileName))
        //    {
        //        SHA256Managed sha = new SHA256Managed();
        //        byte[] checksum = sha.ComputeHash(fs);
        //        return BitConverter.ToString(checksum).Replace("-", String.Empty);
        //    }
        //}
    }

    public class CheckSumEventArgs : EventArgs
    {
        private string m_filename;

        public new static CheckSumEventArgs Empty;

        public string FileName
        {
            get { return m_filename; }
        }

        public CheckSumEventArgs()
            : base()
        {
        }
        public CheckSumEventArgs(string Filename)
            : base()
        {
            m_filename = Filename;
        }
    }

    public delegate void CheckSumEventHandler(object sender, CheckSumEventArgs e);

    /// <summary>
    /// Singleton class for diagnostics (perhaps should be named CheckSum?)
    /// </summary>
   [XmlRootAttribute(ElementName = "Diagnostics")] 
    public  class CheckSums
    {
        public event CheckSumEventHandler FileSaved;
        public event CheckSumEventHandler FileLoaded;

        private string m_filename;

        public string Filename
        {
            get { return m_filename; }
            set { m_filename = value; }
        }

        //public Diagnostics() { }
        private static readonly CheckSums instance = new CheckSums();

        // Explicit static constructor to tell C# compiler
        // not to mark type as beforefieldinit
        static CheckSums() { }
        private CheckSums() {}

        /// <summary>
        /// The public Instance property to use
        /// </summary>
        public static CheckSums CreateInstance
        {
            get { return instance; }
        }


        List<CheckSumFile> m_checksumfiles = new List<CheckSumFile>();

        [XmlElement(ElementName = "CheckSumFile", Type = typeof(CheckSumFile))]
        public List<CheckSumFile> Files
        {
            get { return m_checksumfiles; }
        }

        public static CheckSums GetCheckSumFiles()
        {
            return (CheckSums)ObjectXMLSerializer<CheckSums>.Load(System.IO.Path.Combine(System.Environment.CurrentDirectory, "checksums.xml"));

           //return Load(System.IO.Path.Combine(System.Environment.CurrentDirectory,"Checksums.xml"));
         }

        /// <summary>
        /// Save the contents of this class to an XML file.
        /// No xmlns will be rendered during serialization
        /// </summary>
        /// <param name="Filename">Save to this file</param>
        public void Save(string Filename)
        {
            ObjectXMLSerializer<CheckSums>.Save(this, Filename);
            
            //FileStream stream = null;
            ////Create our own namespaces for the output
            //try
            //{
            //    XmlSerializerNamespaces ns = new XmlSerializerNamespaces();
            //    //Add an empty namespace and empty value
            //    ns.Add("", "");
            //    XmlSerializer serializer = new XmlSerializer(typeof(Diagnostics));
            //    stream = File.Create(Filename); 
            //    serializer.Serialize(stream, this, ns);
            //    serializer = null;
                OnFileSaved(new CheckSumEventArgs(Filename));
            //}
            //catch (Exception ex)
            //{
            //    throw ex;
            //}
            //finally
            //{
            //    if (stream != null)
            //    {
            //        stream.Flush();
            //        stream.Close();
            //        stream = null;
            //    }
            //}
        }

        public virtual void OnFileSaved(CheckSumEventArgs e)
        {
            if (FileSaved != null)
            {
                FileSaved(this, e);
            }
        }

        public virtual void OnFileLoaded(CheckSumEventArgs e)
        {
            if (FileLoaded != null)
            {
                FileLoaded(this, e);
            }
        }
        
        public void Load()
        {
            if (m_filename == string.Empty) throw new ArgumentNullException("Filename cannot be empty");
            CheckSums dgs = ObjectXMLSerializer<CheckSums>.Load(m_filename);
            //Diagnostics dgs = Diagnostics.Load(m_filename);
            this.m_checksumfiles = dgs.Files;
            OnFileLoaded(new CheckSumEventArgs(m_filename));
            ////this.m_checksumfiles = dgs.m_checksumfiles;
            dgs = null;
        }

        /// <summary>
        /// Overloaded method to load in a file which in turn calls
        /// Load(fileStream)
        /// </summary>
        /// <param name="filename">File to load</param>
        /// <returns>Diagnostics class</returns>
        public static CheckSums Load(string Filename)
        {
            return (CheckSums)ObjectXMLSerializer<CheckSums>.Load(Filename);
           // System.IO.Stream stream = new System.IO.FileStream(filename, FileMode.Open, FileAccess.Read);
            //return Load(stream);
        }

        public static CheckSums Load(Stream FileStream)
        {
            CheckSums ret = null;
            //ret = (Diagnostics) ObjectXMLSerializer<Diagnostics>.Load(FileStream);
            try
            {
                XmlSerializer serializer = new XmlSerializer(typeof(CheckSums));
                ret = (CheckSums)serializer.Deserialize(FileStream);
                FileStream.Close();
                return ret;
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show(ex.InnerException.Message, "Loading Checksums", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Error);
            }
            return ret;
        }

        ~CheckSums() 
        {
            // Finalizer calls Dispose(false)
            //Dispose(false);
        }
    }

    [XmlRootAttribute(ElementName = "CheckSumFile")] 
    public class CheckSumFile
    {
        public CheckSumFile() { }

        public CheckSumFile(string FileName)
        {
            m_FileName = FileName;
            CreateCheckSum();
        }

        public CheckSumFile(string FileName,string CheckSum)
        {
            m_FileName = FileName;
            m_CheckSum = CheckSum;
        }

        private string m_CheckSum;
        private string m_FileName;

        [XmlElement(ElementName = "CheckSum")]
        public string CheckSum
        {
            get {return m_CheckSum;}
            set {m_CheckSum =  value;}
        }

        /// <summary>
        /// Uses member variable to produce checksum
        /// </summary>
        public void CreateCheckSum()
        {
            m_CheckSum = Assets.CheckSum.CreateHexCheckSum(m_FileName);
        }

        [XmlElement(ElementName = "File")]
        public string File
        {
            get {return m_FileName;}
            set {m_FileName =  value;}
        }

        
    }


}
