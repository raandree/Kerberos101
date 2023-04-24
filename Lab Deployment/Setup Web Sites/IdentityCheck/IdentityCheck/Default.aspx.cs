using System;
using System.Diagnostics;
using System.Security.Principal;
using System.IO;
using System.Linq;

namespace TestSite1
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            labThreadIdentity.Text = System.Threading.Thread.CurrentPrincipal.Identity.Name;

            /////////////////////////////////////////////////////////

            try
            {
                labWindowsIdentity.Text = WindowsIdentity.GetCurrent().User.Translate(typeof(NTAccount)).Value;
            }
            catch { }
            var groups = string.Empty;

            foreach (var group in WindowsIdentity.GetCurrent().Groups)
            {
                try
                {
                    groups += group.Translate(typeof(System.Security.Principal.NTAccount)).Value + Environment.NewLine;
                }
                catch { }
            }
            txtGroups.Text = groups;

            /////////////////////////////////////////////////////////

            var startInfo = new ProcessStartInfo("whoami.exe");
            startInfo.RedirectStandardInput = true;
            startInfo.RedirectStandardOutput = true;
            startInfo.UseShellExecute = false;
            startInfo.WindowStyle = ProcessWindowStyle.Hidden;

            var p = Process.Start(startInfo);

            labWhoAmI.Text = p.StandardOutput.ReadToEnd();
        }

        protected void btnAccessFolder_Click(object sender, EventArgs e)
        {
            try
            {
                int itemCount = 0;

                var di = new DirectoryInfo(txtFolderPath.Text);
                
                itemCount = di.GetFiles().Length;
                itemCount += di.GetDirectories().Length;

                labAccessFolderMessage.Text = string.Format("Folder has {0} items", itemCount);
            }
            catch (Exception ex)
            {
                labAccessFolderMessage.Text = ex.Message;
            }
        }
    }
}