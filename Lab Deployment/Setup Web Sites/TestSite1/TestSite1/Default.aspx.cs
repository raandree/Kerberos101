using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Data;

namespace TestSite1
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            labThreadIdentity.Text = System.Threading.Thread.CurrentPrincipal.Identity.Name;
        }

        protected void btnGo_Click(object sender, EventArgs e)
        {
            var connectionString = string.Format("Data Source={0};Initial Catalog=pubs;Integrated Security=SSPI;", TextBox1.Text);

            SqlConnection connection = new System.Data.SqlClient.SqlConnection(connectionString);
            connection.Open();

            SqlCommand command = new SqlCommand();
            command.Connection = connection;
            command.CommandText = "SELECT * FROM authors";
            command.CommandType = CommandType.Text;

            SqlDataAdapter dataAdapter = new SqlDataAdapter();
            dataAdapter.SelectCommand = command;
            DataSet dataSet = new DataSet();
            dataAdapter.Fill(dataSet);

            labRecordsRead.Text = dataSet.Tables[0].Rows.Count.ToString();

            connection.Close();
        }
    }
}