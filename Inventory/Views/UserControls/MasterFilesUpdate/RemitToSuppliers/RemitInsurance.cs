using Inventory.Interfaces;
using Inventory.Models;
using Microsoft.EntityFrameworkCore.Query.Internal;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    public partial class RemitInsurance : UserControl, IActiveControlManager
    {
        // --- class variables --- //
        private readonly IActiveControlManager _activeControlHelper;
        private readonly MainWindow _mainWindow;
        private readonly AmerichickenContext dbContext;
        private rem_sup? remitData;
        public RemitInsurance(MainWindow mainWindow, IActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _activeControlHelper = activeControlManager;
            _mainWindow = mainWindow;
            dbContext = new AmerichickenContext();
        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("Remit Insurance");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Cancel");
        }

        public void GetRemitInsuranceData(rem_sup remitToObject)
        {
            remitData = remitToObject;
            insTp1TextBox.Text = remitToObject.ins_tp1?.Trim() ?? "";
            insTp2TextBox.Text = remitToObject.ins_tp2?.Trim() ?? "";
            insTp3TextBox.Text = remitToObject.ins_tp3?.Trim() ?? "";
            insTp4TextBox.Text = remitToObject.ins_tp4?.Trim() ?? "";
            insTp5TextBox.Text = remitToObject.ins_tp5?.Trim() ?? "";
            policy1TextBox.Text = remitToObject.policy1?.Trim() ?? "";
            genBeginDateMaskBox.Text = remitToObject.gen_beg?.ToString("MM/dd/yyyy").Trim() ?? "";
            genEndDateMaskBox.Text = remitToObject.gen_end?.ToString("MM/dd/yyyy").Trim() ?? "";
            genLetterSentDateMaskBox.Text = remitToObject.gen_let?.ToString("MM/dd/yyyy").Trim() ?? "";
            genCov1TextBox.Text = remitToObject.gen_cov1?.ToString().Trim() ?? "";
            genCov2TextBox.Text = remitToObject.gen_cov2?.ToString().Trim() ?? "";
            genCov3TextBox.Text = remitToObject.gen_cov3?.ToString().Trim() ?? "";
            genCov4TextBox.Text = remitToObject.gen_cov4?.ToString().Trim() ?? "";
            genCov5TextBox.Text = remitToObject.gen_cov5?.ToString().Trim() ?? "";
            genCov6TextBox.Text = remitToObject.gen_cov6?.ToString().Trim() ?? "";
            policy2TextBox.Text = remitToObject.policy2?.Trim() ?? "";
            autoBeginDateMaskBox.Text = remitToObject.auto_beg?.ToString("MM/dd/yyyy").Trim() ?? "";
            autoEndDateMaskBox.Text = remitToObject.auto_end?.ToString("MM/dd/yyyy").Trim() ?? "";
            autoLetterSentDateMaskBox.Text = remitToObject.auto_let?.ToString("MM/dd/yyyy").Trim() ?? "";
            autoCov1TextBox.Text = remitToObject.auto_cov1?.ToString().Trim() ?? "";
            autoCov2TextBox.Text = remitToObject.auto_cov2?.ToString().Trim() ?? "";
            autoCov3TextBox.Text = remitToObject.auto_cov3?.ToString().Trim() ?? "";
            autoCov4TextBox.Text = remitToObject.auto_cov4?.ToString().Trim() ?? "";
            policy3TextBox.Text = remitToObject.policy3?.Trim() ?? "";


        }
        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    //save
                    break;
                case "2":
                    //edit
                    break;
                case "3":
                    //cancel
                    break;
                default:
                    MessageBox.Show("Invalid input, please try again or contact developer");
                    break;
            }
        }
    }
}
