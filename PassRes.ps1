Add-Type -AssemblyName PresentationFramework

Function Generate-Password(){
For($i=0;$i -lt 12; $i++){
$rnd=(Get-Random(74))+48
$char=[char]$rnd
$pwd += $char}
Return $pwd
}

Function Set-Password($user, $password){
Get-ADUser $user | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)
}

Function Email-Password($user, $email, $message){
$subject = "New Password for $user"
$body = $message
$params = @{ 
    Body = $body 
    BodyAsHtml = $true 
    Subject = $subject 
    From = 'alias@yourdomain.com' 
    To = $email 
    SmtpServer = 'mail.yourdomain.com' 
    Port = 587 
    Credential = $cred
    UseSsl = $true 
} 
Send-MailMessage @params
}



[xml]$Form  = Get-Content "C:\Users\ariga\Learn\Pluralsight\Building Windows PowerShell GUIs in WPF for Free\PasswordReset\App.xaml"
$NR=(New-Object System.Xml.XmlNodeReader $Form)
$Win=[Windows.Markup.XamlReader]::Load( $NR )

$user = $win.FindName("UserName")
$pwd = $win.FindName("Password")
$gen = $win.FindName("GeneratePassword")
$Update = $win.FindName("Update")

$gen.Add_Click({
$password = Generate-Password
$pwd.text=$password
})

$Update.Add_Click({
Try{$usr = Get-Aduser $user.Text -Properties EmailAddress}Catch{$usr=$null} 
$alias = $usr.SamAccountName
$email = $usr.EmailAddress
$password = $pwd.Text
If($password -eq ""){
[System.Windows.MessageBox]::Show("Please make sure that the Password has been generated before you send email.", "Password Error")
}ElseIf($usr -eq $null){
[System.Windows.MessageBox]::Show("Please enter a valid UserName before clicking Update and Send.", "User Error")
}Else{
Set-Password $alias $password
$message="Your password has been reset. Your new password is $password and it must be changes on first use."
Email-Password $alias $email $Message
[System.Windows.MessageBox]::Show("Password for $alias has been updated to be $password and an email has been sent to $email.", "Update Completed")
$user.text=""
$pwd.text=""}
})



$Win.showdialog()