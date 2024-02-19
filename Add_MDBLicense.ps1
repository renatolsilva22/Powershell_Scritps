Connect-AzureAD

$Users =  Get-AzureADUser -All $true | Where-Object {$_.ExtensionProperty.onPremisesDistinguishedName -like "*OU=Workstations*"}
$MSFDefenderID = "7197e941-f33b-4ab4-b799-a24aecf6cb2f_5e1e7702-a2b7-4360-8d07-2f515792896f" 
$MSFDefender_Name = "MDE_SMB"
$Microsoft_DBLicense = Get-AzureADSubscribedSku -ObjectID $MSFDefenderID
$License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense 
$License.SkuId = $Microsoft_DBLicense.SkuId
$Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$Licenses.AddLicenses = $License


foreach ($user in $Users)
{
    ##Check if Licence is already assigned
    $User_License_Detail = (Get-AzureADUserLicenseDetail -objectID $user.ObjectId).ServicePlans
   
    if($User_License_Detail.ServicePlanName -contains $MSFDefender_Name) 
    {
        Write-Host "Utilizador $($user.DisplayName) já possui a licença atribuída."
    }
    else 
    {
        Set-AzureADUserLicense -ObjectId $User.ObjectId -AssignedLicenses $Licenses
        Write-Host "A atribuir licença $($user.DisplayName)"
    }
}