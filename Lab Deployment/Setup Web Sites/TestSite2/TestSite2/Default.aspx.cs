using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Security.Principal;
using System.Data.SqlClient;
using System.Data;

namespace TestSite2
{
    public partial class _Default : System.Web.UI.Page
    {
        string temp = string.Empty;

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnGo_Click(object sender, EventArgs e)
        {
            // The WindowsIdentity(string) constructor uses the new
            // Kerberos S4U extension to get a logon for the user
            // without a password.
            WindowsIdentity wi = new WindowsIdentity(txtCredentials.Text);
            WindowsImpersonationContext wic = null;
            try
            {
                wic = wi.Impersonate();
                // Code to access network resources goes here.
                labResult.Text = "|" + wi.Name + "|";

                SqlConnection connection = new System.Data.SqlClient.SqlConnection("Data Source=kerbsql22;Initial Catalog=pubs;Integrated Security=SSPI;");
                connection.Open();

                SqlCommand command = new SqlCommand();
                command.Connection = connection;
                command.CommandText = "SELECT * FROM authors";
                command.CommandType = CommandType.Text;

                SqlDataAdapter dataAdapter = new SqlDataAdapter();
                dataAdapter.SelectCommand = command;
                DataSet dataSet = new DataSet();
                dataAdapter.Fill(dataSet);

                labRecordsRead.Text = "Number of records read from pubs: " + dataSet.Tables[0].Rows.Count.ToString();

                connection.Close();
            }
            catch(Exception ex)
            {
                // Ensure that an exception is not propagated higher in the call stack.
                throw ex;
            }
            finally
            {
                // Make sure to remove the impersonation token
                if (wic != null)
                    wic.Undo();
            }

            btnGo.Enabled = false;

        }
    }
}