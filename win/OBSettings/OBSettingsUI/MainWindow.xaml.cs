using System.Runtime.CompilerServices;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace OBSettingsUI
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {

        private string default_config_dir_name = ".obsidian";

        /// <summary>
        /// 清输入的Vault的路径
        /// </summary>
        private void ClearVaultPath()
        {
            txb_vault_root.Text = string.Empty;
        }

        /// <summary>
        /// 重置配置目录名
        /// 重置为 .obsidian
        /// </summary>
        private void ResetConfigDirName()
        {
            // 设为默认值，即 .obsidian
            txb_configdirname.Text = default_config_dir_name;
        }


        /// <summary>
        /// 清理各种输入
        /// </summary>
        private void Reset()
        {
            ClearVaultPath();
        }

        /// <summary>
        /// 初始化界面
        /// </summary>
        private void Init_compen()
        {
            Reset();
        }


        public MainWindow()
        {
            InitializeComponent();
            Init_compen();
        }

        #region 选择目录按钮单击事件
        /// <summary>
        /// 选择目录按钮单击事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btn_select_vroot_Click(object sender, RoutedEventArgs e)
        {
            // 目录对话框
            Microsoft.Win32.OpenFolderDialog dirDialog = new();

            dirDialog.Multiselect = false;

            // 是否打开对话框
            bool? open_result = dirDialog.ShowDialog();

            if (open_result == true)
            {
                // 获取目录完整路径
                string fullPathFolder = dirDialog.FolderName;
                // 将路径加入输入框
                txb_vault_root.Text = fullPathFolder;
            }


        }
        #endregion 选择目录按钮单击事件

        #region 清理按钮单击事件
        /// <summary>
        /// 清理按钮单击事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btn_clear_Click(object sender, RoutedEventArgs e)
        {
            // 清除输入的Vault的路径
            ClearVaultPath();
        }
        #endregion 清理按钮单击事件

        #region 重置配置目录名单击事件
        /// <summary>
        /// 重置配置目录名单击事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btn_reset_confdirname_Click(object sender, RoutedEventArgs e)
        {
            ResetConfigDirName();
        }
        #endregion 重置配置目录名单击事件

        #region 选择配置目录按钮单击事件
        /// <summary>
        /// 选择配置目录按钮单击事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btn_select_confdirname_Click(object sender, RoutedEventArgs e)
        {
            Microsoft.Win32.OpenFolderDialog configdir_dialog = new();
            // 禁止多选
            configdir_dialog.Multiselect = false;

            bool? select_config_result = configdir_dialog.ShowDialog();

            if (select_config_result == true)
            {
                // 获取配置目录名
                // 只有目录名，不包含完整路径
                txb_configdirname.Text = configdir_dialog.SafeFolderName;
            }

        }
        #endregion 选择配置目录按钮单击事件
    }
}