using Inventory.Interfaces;
using Inventory.Models;
using System.Globalization;
using Inventory.Services;

namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    public partial class RemitInsurance : UserControl, IActiveControlManager
    {
        // --- class variables --- //
        private readonly ActiveControlManager _activeControlHelper;
        private readonly MainWindow _mainWindow;
        private readonly AmerichickenContext dbContext;
        private rem_sup _remitData;
        public RemitInsurance(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _activeControlHelper = activeControlManager;
            _mainWindow = mainWindow;
            dbContext = new AmerichickenContext();
            this.Load += (s, e) => insTp1TextBox.Focus();
        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("Remit Insurance");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Cancel    4. Main Menu");
        }

        private void SetTextBoxText(TextBox textBox, object? value)
        {
            textBox.Text = StringServices.TrimOrNull(value.ToString());
        }

        private void SetMaskedTextBoxText(MaskedTextBox maskedTextBox, DateTime? value)
        {
            maskedTextBox.Text = value.HasValue ? StringServices.TrimOrNull(value.Value.ToString("MM/dd/yyyy")) : null;
        }

        public void DisplayRemitInsuranceData(rem_sup remitToObject)
        {
            _remitData = remitToObject;

            var textBoxMapping = new Dictionary<TextBox, object?>
            {
                {insTp1TextBox, _remitData.ins_tp1},
                {insTp2TextBox, _remitData.ins_tp2},
                {insTp3TextBox, _remitData.ins_tp3},
                {insTp4TextBox, _remitData.ins_tp4},
                {insTp5TextBox, _remitData.ins_tp5},
                {policy1TextBox, _remitData.policy1},
                {genCov1TextBox, _remitData.gen_cov1},
                {genCov2TextBox, _remitData.gen_cov2},
                {genCov3TextBox, _remitData.gen_cov3},
                {genCov4TextBox, _remitData.gen_cov4},
                {genCov5TextBox, _remitData.gen_cov5},
                {genCov6TextBox, _remitData.gen_cov6},
                {policy2TextBox, _remitData.policy2},
                {autoCov1TextBox, _remitData.auto_cov1},
                {autoCov2TextBox, _remitData.auto_cov2},
                {autoCov3TextBox, _remitData.auto_cov3},
                {autoCov4TextBox, _remitData.auto_cov4},
                {policy3TextBox, _remitData.policy3},
                {excessCov1TextBox, _remitData.exce_cov1},
                {excessCov2TextBox, _remitData.exce_cov2},
                {policy4TextBox, _remitData.policy4},
                {workCov1TextBox, _remitData.work_cov1},
                {workCov2TextBox, _remitData.work_cov2},
                {workCov3TextBox, _remitData.work_cov3},
                {policy5TextBox, _remitData.policy5},
                {recallCov1TextBox, _remitData.reca_cov1},
                {cancellationTextBox, _remitData.cancel},
            };

            var maskedTextBoxMapping = new Dictionary<MaskedTextBox, DateTime?>
            {
                {genBeginDateMaskBox, _remitData.gen_beg},
                {genEndDateMaskBox, _remitData.gen_end},
                {genLetterSentDateMaskBox, _remitData.gen_let},
                {autoBeginDateMaskBox, _remitData.auto_beg},
                {autoEndDateMaskBox, _remitData.auto_end},
                {autoLetterSentDateMaskBox, _remitData.auto_let},
                {excessBeginDateMaskBox, _remitData.exces_beg},
                {excessEndDateMaskBox, _remitData.exces_end},
                {excessLetterSentDateMaskBox, _remitData.exces_let},
                {workBeginDateMaskBox, _remitData.work_beg},
                {workEndDateMaskBox, _remitData.work_end},
                {workLetterSentDateMaskBox, _remitData.work_let},
                {recallBeginDateMaskBox, _remitData.recal_beg},
                {recallEndDateMaskBox, _remitData.recal_end},
                {recallLetterSentDateMaskBox, _remitData.recal_let},
            };

            foreach (var pair in textBoxMapping)
            {
                SetTextBoxText(pair.Key, pair.Value);
            }

            foreach (var pair in maskedTextBoxMapping)
            {
                SetMaskedTextBoxText(pair.Key, pair.Value);
            }
        }

        public void UpdateRemitInsuranceData(rem_sup remitToData)
        {
            if (remitToData != null)
            {
                if (IsDataModified(remitToData))
                {
                    var existingRemData = dbContext.rem_sup.Find(remitToData.PK_rem_sup);
                    if (existingRemData != null)
                    {
                        var textBoxMapping = new Dictionary<TextBox, Action<string>>
                        {
                            { insTp1TextBox, value => existingRemData.ins_tp1 = StringServices.TrimOrNull(value) },
                            { insTp2TextBox, value => existingRemData.ins_tp2 = StringServices.TrimOrNull(value) },
                            { insTp3TextBox, value => existingRemData.ins_tp3 = StringServices.TrimOrNull(value) },
                            { insTp4TextBox, value => existingRemData.ins_tp4 = StringServices.TrimOrNull(value) },
                            { insTp5TextBox, value => existingRemData.ins_tp5 = StringServices.TrimOrNull(value) },
                            { policy1TextBox, value => existingRemData.policy1 = StringServices.TrimOrNull(value) },
                            { policy2TextBox, value => existingRemData.policy2 = StringServices.TrimOrNull(value) },
                            { policy3TextBox, value => existingRemData.policy3 = StringServices.TrimOrNull(value) },
                            { policy4TextBox, value => existingRemData.policy4 = StringServices.TrimOrNull(value) },
                            { policy5TextBox, value => existingRemData.policy5 = StringServices.TrimOrNull(value) },  
                        };

                        var maskedTextBoxMapping = new Dictionary<MaskedTextBox, Action<DateTime?>>
                        {
                            { genBeginDateMaskBox, value => existingRemData.gen_beg = value },
                            { genEndDateMaskBox, value => existingRemData.gen_end = value },
                            { genLetterSentDateMaskBox, value => existingRemData.gen_let = value },
                            { autoBeginDateMaskBox, value => existingRemData.auto_beg = value },
                            { autoEndDateMaskBox, value => existingRemData.auto_end = value },
                            { autoLetterSentDateMaskBox, value => existingRemData.auto_let = value },
                            { excessBeginDateMaskBox, value => existingRemData.exces_beg = value },
                            { excessEndDateMaskBox, value => existingRemData.exces_end = value },
                            { excessLetterSentDateMaskBox, value => existingRemData.exces_let = value },
                            { workBeginDateMaskBox, value => existingRemData.work_beg = value },
                            { workEndDateMaskBox, value => existingRemData.work_end = value },
                            { workLetterSentDateMaskBox, value => existingRemData.work_let = value },
                            { recallBeginDateMaskBox, value => existingRemData.recal_beg = value },
                            { recallEndDateMaskBox, value => existingRemData.recal_end = value },
                            { recallLetterSentDateMaskBox, value => existingRemData.recal_let = value },
                        };

                        var decimalTextBoxMapping = new Dictionary<TextBox, Action<decimal?>>
                        {
                            { genCov1TextBox, value => existingRemData.gen_cov1 = decimal.TryParse(value.ToString(), out var genCov1) ? genCov1 : null },
                            { genCov2TextBox, value => existingRemData.gen_cov2 = decimal.TryParse(value.ToString(), out var genCov2) ? genCov2 : null },
                            { genCov3TextBox, value => existingRemData.gen_cov3 = decimal.TryParse(value.ToString(), out var genCov3) ? genCov3 : null },
                            { genCov4TextBox, value => existingRemData.gen_cov4 = decimal.TryParse(value.ToString(), out var genCov4) ? genCov4 : null },
                            { genCov5TextBox, value => existingRemData.gen_cov5 = decimal.TryParse(value.ToString(), out var genCov5) ? genCov5 : null },
                            { genCov6TextBox, value => existingRemData.gen_cov6 = decimal.TryParse(value.ToString(), out var genCov6) ? genCov6 : null },
                            { autoCov1TextBox, value => existingRemData.auto_cov1 = decimal.TryParse(value.ToString(), out var autoCov1) ? autoCov1 : null },
                            { autoCov2TextBox, value => existingRemData.auto_cov2 = decimal.TryParse(value.ToString(), out var autoCov2) ? autoCov2 : null },
                            { autoCov3TextBox, value => existingRemData.auto_cov3 = decimal.TryParse(value.ToString(), out var autoCov3) ? autoCov3 : null },
                            { autoCov4TextBox, value => existingRemData.auto_cov4 = decimal.TryParse(value.ToString(), out var autoCov4) ? autoCov4 : null },
                            { excessCov1TextBox, value => existingRemData.exce_cov1 = decimal.TryParse(value.ToString(), out var excessCov1) ? excessCov1 : null },
                            { excessCov2TextBox, value => existingRemData.exce_cov2 = decimal.TryParse(value.ToString(), out var excessCov2) ? excessCov2 : null },
                            { workCov1TextBox, value => existingRemData.work_cov1 = decimal.TryParse(value.ToString(), out var workCov1) ? workCov1 : null },
                            { workCov2TextBox, value => existingRemData.work_cov2 = decimal.TryParse(value.ToString(), out var workCov2) ? workCov2 : null },
                            { workCov3TextBox, value => existingRemData.work_cov3 = decimal.TryParse(value.ToString(), out var workCov3) ? workCov3 : null },
                            { recallCov1TextBox, value => existingRemData.reca_cov1 = decimal.TryParse(value.ToString(), out var recall) ? recall : null },
                            { cancellationTextBox, value => existingRemData.cancel = decimal.TryParse(value.ToString(), out var cancellation) ? cancellation : null },
                        };

                        foreach (var pair in textBoxMapping)
                        {
                            if (!string.IsNullOrWhiteSpace(pair.Key.Text))
                            {
                                pair.Value(pair.Key.Text);
                            }
                        }

                        foreach (var pair in maskedTextBoxMapping)
                        {
                            if (!string.IsNullOrWhiteSpace(pair.Key.Text))
                            {
                                if (DateTime.TryParse(pair.Key.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var date))
                                {
                                    pair.Value(date);
                                }
                            }
                        }

                        foreach (var pair in decimalTextBoxMapping)
                        {
                            if (!string.IsNullOrWhiteSpace(pair.Key.Text))
                            {
                                if (decimal.TryParse(pair.Key.Text, out var decimalValue))
                                {
                                    pair.Value(decimalValue);
                                }
                                else
                                {
                                    MessageBox.Show($"ERROR: {pair.Key.Name} is not a valid decimal value. Please try again or contact developer.");
                                }
                            }
                        }

                        dbContext.SaveChanges();
                        _remitData = existingRemData;
                    }
                    else
                    {
                        MessageBox.Show("ERROR: Remit Data not found in database. Please try again or contact developer.");
                    }
                }
            }
            else
            {
                MessageBox.Show("ERROR: Remit Data is null trying to update insurance info. Please try again or contact developer.");
            }
        }

        public bool IsDataModified(rem_sup remitToData)
        {
            return remitToData == null || remitToData.ins_tp1 != StringServices.TrimOrNull(insTp1TextBox.Text) ||
                   remitToData.ins_tp2 != StringServices.TrimOrNull(insTp2TextBox.Text) ||
                   remitToData.ins_tp3 != StringServices.TrimOrNull(insTp3TextBox.Text) ||
                   remitToData.ins_tp4 != StringServices.TrimOrNull(insTp4TextBox.Text) ||
                   remitToData.ins_tp5 != StringServices.TrimOrNull(insTp5TextBox.Text) ||
                   remitToData.policy1 != StringServices.TrimOrNull(policy1TextBox.Text) ||
                   remitToData.gen_beg != DateTime.Parse(genBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.gen_end != DateTime.Parse(genEndDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.gen_let != DateTime.Parse(genLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.gen_cov1 != decimal.Parse(genCov1TextBox.Text.Trim()) ||
                   remitToData.gen_cov2 != decimal.Parse(genCov2TextBox.Text.Trim()) ||
                   remitToData.gen_cov3 != decimal.Parse(genCov3TextBox.Text.Trim()) ||
                   remitToData.gen_cov4 != decimal.Parse(genCov4TextBox.Text.Trim()) ||
                   remitToData.gen_cov5 != decimal.Parse(genCov5TextBox.Text.Trim()) ||
                   remitToData.gen_cov6 != decimal.Parse(genCov6TextBox.Text.Trim()) ||
                   remitToData.policy2 != StringServices.TrimOrNull(policy2TextBox.Text) ||
                   remitToData.auto_beg != DateTime.Parse(autoBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.auto_end != DateTime.Parse(autoEndDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.auto_let != DateTime.Parse(autoLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.auto_cov1 != decimal.Parse(autoCov1TextBox.Text.Trim()) ||
                   remitToData.auto_cov2 != decimal.Parse(autoCov2TextBox.Text.Trim()) ||
                   remitToData.auto_cov3 != decimal.Parse(autoCov3TextBox.Text.Trim()) ||
                   remitToData.auto_cov4 != decimal.Parse(autoCov4TextBox.Text.Trim()) ||
                   remitToData.policy3 != StringServices.TrimOrNull(policy3TextBox.Text) ||
                   remitToData.exces_beg != DateTime.Parse(excessBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.exces_end != DateTime.Parse(excessEndDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.exces_let != DateTime.Parse(excessLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.exce_cov1 != decimal.Parse(excessCov1TextBox.Text.Trim()) ||
                   remitToData.exce_cov2 != decimal.Parse(excessCov2TextBox.Text.Trim()) ||
                   remitToData.policy4 != StringServices.TrimOrNull(policy4TextBox.Text) ||
                   remitToData.work_beg != DateTime.Parse(workBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.work_end != DateTime.Parse(workEndDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.work_let != DateTime.Parse(workLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.work_cov1 != decimal.Parse(workCov1TextBox.Text.Trim()) ||
                   remitToData.work_cov2 != decimal.Parse(workCov2TextBox.Text.Trim()) ||
                   remitToData.work_cov3 != decimal.Parse(workCov3TextBox.Text.Trim()) ||
                   remitToData.policy5 != StringServices.TrimOrNull(policy5TextBox.Text) ||
                   remitToData.recal_beg != DateTime.Parse(recallBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.recal_end != DateTime.Parse(recallEndDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.recal_let != DateTime.Parse(recallLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.reca_cov1 != decimal.Parse(recallCov1TextBox.Text.Trim()) ||
                   remitToData.cancel != decimal.Parse(cancellationTextBox.Text.Trim());
        }
        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    //save
                    UpdateRemitInsuranceData(_remitData);
                    break;
                case "2":
                    //edit
                    insTp1TextBox.Focus();
                    break;
                case "3":
                    //cancel
                    RemitToUpdateInfo remitInstance = new(_mainWindow, _activeControlHelper);
                    remitInstance.DisplayRemitToData(_remitData);
                    _mainWindow.DisposeControl(this);
                    _activeControlHelper.SetActiveControl(remitInstance);

                    break;
                case "4":
                    //main menu
                    _mainWindow.DisposeControl(this);
                    _activeControlHelper.SetActiveControl(new MenuList(_mainWindow, _activeControlHelper));
                    break;
                default:
                    MessageBox.Show("Invalid input, please try again or contact developer");
                    break;
            }
        }
    }
}