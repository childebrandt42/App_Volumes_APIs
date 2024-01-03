<#
.SYNOPSIS
    Powershell Code for App Volumes APIs
.DESCRIPTION
    Detailed example of how to use the App Volumes APIs and code examples.
.PARAMETER ParameterName
    Description of the parameter.
.EXAMPLE
    Example usage of the script or function.
.NOTES
    Version:          1.0.0
    Author:           Chris Hildebrandt
    twitter:          @childebrandt42
    Date Created:     1/1/2024
    Date Updated:     1/1/2024
#>

################################################################################################################################
#--------------------------------------------Connect to App Volumes Server-----------------------------------------------------#
################################################################################################################################

# Server Address
$AppVolServer = "AppVol.chrislab.local"

# Import Creds from Creds manager
$Creds = Get-StoredCredential -Target "Chris@chrislab.local"

# Set Up Creds Header for App Volumes
$RESTAPIUser = $Creds.UserName
$RESTAPIPassword = $Creds.GetNetworkCredential().password

$AppVolRestCreds = @{
    username = $RESTAPIUser
    password = $RESTAPIPassword
}

# Create your App Volumes Session
$AppVolServerRest = Invoke-RestMethod -SessionVariable SourceServerSession -Method Post -Uri "https://$AppVolServer/cv_api/sessions" -Body $AppVolRestCreds

################################################################################################################################
#----------------------------------------------------Random Commands-----------------------------------------------------------#
################################################################################################################################

# Get - - Version
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/version"

# Get - - AD Settings
Invoke-RestMethod -Websession $SourceServerSession -Method Get -Uri https://$AppVolServer/cv_api/ad_settings


################################################################################################################################
#-----------------------------------------Inventory Tab on App Volumes Server--------------------------------------------------#
################################################################################################################################

#______________________________________________________________________________________
# Applications

# Get - Applications
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products"

# Get - Application Packages 
# You will need to get Application ID from the Applications command from above.
$ProductID = $Product.id
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$ProductID/app_packages?include=app_markers"

# Get - Application Assignments
# You will need to get Application ID from the Applications command from above.
$ProductID = $Product.id
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_products/$ProductID/assignments?include=entities"

# Put - Set App Package as Current
# You will need to get Application ID from the Applications for this we will use $ProductID and you will need Package ID from Packages for this we will use $AppPackageID
Invoke-RestMethod -WebSession $SourceServerSession -Method put -Uri "https://$AppVolServer/app_volumes/app_products/$ProductID/app_markers/CURRENT?data%5Bapp_package_id%5D=$AppPackageID"

# Delete - Remove Application
# You will need to get Application ID from the Applications for this we will use $ProductID
Invoke-RestMethod -WebSession $SourceServerSession -Method Delete -Uri "https://$AppVolServer/app_volumes/app_products/$ProductID"

#______________________________________________________________________________________
# Packages

# Get - Packages
Invoke-RestMethod -WebSession $SourceServerSession -Method get -Uri "https://$AppVolServer/app_volumes/app_packages?include=app_markers%2Clifecycle_stage%2Cbase_app_package%2Capp_product"

# Get - Package Programs
# You will need o get App Package ID from the Packages command. 
$AppPackageID = $AppPackage.id
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$AppPackageID/programs"

# Get - Package Opperating Systems
# You will need o get App Package ID from the Packages command. 
$AppPackageID = $AppPackage.id
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$AppPackageID/operating_systems"

# Get - Package Storage Locations
# You will need o get App Package ID from the Packages command. 
$AppPackageID = $AppPackage.id
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$AppPackageID/files"

# Get - Package Application Links
# You will need o get App Package ID from the Packages command. 
$AppPackageID = $AppPackage.id
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$AppPackageID/app_links?"

# Get - Lifecycle List
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/lifecycle_stages"

# Put - Set App Package Lifecycle Stage
# To set Lifecycle Stage you need a few things. App Package ID and for this we are using $AppPackageID, and the lifecycle stage ID you want to set, for this we are using $LifecycleID.
Invoke-RestMethod -WebSession $TargetServerSession -Method put -Uri "https://$AppVolServer/app_volumes/app_packages/$AppPackageID?data%5Blifecycle_stage_id%5D=$LifecycleID"

#______________________________________________________________________________________
# Programs

# Get - Programs
Invoke-RestMethod -WebSession $SourceServerSession -Method get -Uri "https://$AppVolServer/app_volumes/app_programs"

#______________________________________________________________________________________
# Assignments

# Get - Assignments
Invoke-RestMethod -WebSession $SourceServerSession -Method get -Uri "https://$AppVolServer/app_volumes/app_assignments?include=entities,filters,app_package,app_marker"

# Post - Unassign Users or Groups
# Will need an Assignment ID for what you want to remove, for this we are using $AssignmentID
Invoke-RestMethod  -WebSession $SourceServerSession -Method Post -Uri "https://$AppVolServer/app_volumes/app_assignments/delete_batch?ids%5B%5D=$AssignmentID"

# Post - Assign User or Group
# This one is fun. Requires some prework we need to create a Body for this. But will require a few things
# You will need Product ID so for this we are using $ProductID
# You will need User or Group ID for this we are using $UserGroupID
# You will need to know if 'User' or 'Group' for this we are going ot Set $Type = 'User'
# If you want to set user to "Package" you will need to know package ID, if not that needs to be set to null, and if you do you need to set "Marker to null.
# If you want to set user to "Current" you need to set the value of app_package to null, and then set app_marker_name to "CURRENT" for this we are using $Marker = "CURRENT"
# You will need to know the Application ID you plan to use, so for this we are going to use $ProductID
$AssignmentJsonBody = "{""data"":[{""app_product_id"":$ProductID,""entities"":[{""path"":""$UserGroupID"",""entity_type"":""$Type""}],""app_package_id"":null,""app_marker_name"":""$Marker"",""app_marker_id"":$ProductID}]}"
# now you can run the following command after you build the body
Invoke-RestMethod  -WebSession $SourceServerSession -Method Post -Uri "https://$AppVolServer/app_volumes/app_assignments" -Body $AssignmentJsonBody -ContentType 'application/json'

#______________________________________________________________________________________
# Attachments

# Get - Assignments App Markers
# You will need to get Assignment ID and enter into command
$AssignmentID = $Assignment.id
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_packages/$AssignmentID/programs"

# Get - App Attachments
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/app_attachments"

# Get - Writeable Volumes
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/writables"

################################################################################################################################
#-----------------------------------------Directory Tab on App Volumes Server--------------------------------------------------#
################################################################################################################################

#______________________________________________________________________________________
# Online Users

# Get - Online Users
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/online_entities"

#______________________________________________________________________________________
# Users

# Get - Users
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/users"
# if you want to filter out deleted
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/users?deleted=hide"

#______________________________________________________________________________________
# Computers

# Get - Computers
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/computers"
# if you want to filter out deleted
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/computers?deleted=hide"

#______________________________________________________________________________________
# Groups

# Get - Groups
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/groups"
# if you want to filter out deleted
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/groups?deleted=hide"

#______________________________________________________________________________________
# Organizational Units

# Get - OU's
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/org_units"
# if you want to filter out deleted
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/org_units?deleted=hide"

################################################################################################################################
#--------------------------------------Infrasctucture Tab on App Volumes Server------------------------------------------------#
################################################################################################################################

#______________________________________________________________________________________
# Machines

# Get - Machines
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machines"
# if you want to filter out deleted
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machines?deleted=hide"

#______________________________________________________________________________________
# Storages

# Get - Storages
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storages"
# if you want to filter out deleted
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storages?deleted=hide"

# Put - Mark Data Store as Non-Attachable
# You will need the DataStore ID to mark, for this example we are going to use varivle $StorageID
Invoke-WebRequest -WebSession $SourceServerSession -Method put -Uri "https://$AppVolServer/cv_api/storages/mark_attach_action?ids%5B%5D=$StorageID&mark_attach_action=no_attach"

#______________________________________________________________________________________
# Storage Groups

# Get - Storage groups
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storage_groups"

# Post - Rescan Storage Group
# You will need the Storage Group ID to mark, for this example we are going to use varivle $GroupID
Invoke-RestMethod -WebSession $SourceServerSession -Method Post -Uri "https://$AppVolServer/cv_api/storage_groups/$GroupID/rescan"

# Post - Import Apps for Storage Group
# You will need the Storage Group ID to mark, for this example we are going to use varivle $GroupID
Invoke-RestMethod -WebSession $SourceServerSession -Method Post -Uri "https://$AppVolServer/cv_api/storage_groups/$GroupID/import"

# Post - Replicate the Storage Group
# You will need the Storage Group ID to mark, for this example we are going to use varivle $GroupID
Invoke-RestMethod -WebSession $SourceServerSession -Method Post -Uri "https://$AppVolServer/cv_api/storage_groups/$GroupID/replicate"

#______________________________________________________________________________________
# Instances 

# Get - Instances
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/manager_instances/related?api_version=4050"

#______________________________________________________________________________________
# Pending Actions

# Get - Pending Actions
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/jobs/pending"

#______________________________________________________________________________________
# Jobs

# Get - Jobs
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/jobs"

#______________________________________________________________________________________
# Activity Logs

# Get - Activity Logs
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/activity_logs"

#______________________________________________________________________________________
# System Messages

# Get - System Messages
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/system_messages"

#______________________________________________________________________________________
# Troubleshooting Archives

# Get - Troubleshooting Archives
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/troubleshooting_archive"

#______________________________________________________________________________________
# Licnese Information

# Get - License Information
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/license"

#______________________________________________________________________________________
# Active Directory Domains

# Get - Active Directory Domains
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/ldap_domains"

#______________________________________________________________________________________
# Administrator Roles

# Get - Administrator Roles
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/group_permissions"

#______________________________________________________________________________________
# Machine Managers

# Get - Machine Managers
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers"

#______________________________________________________________________________________
# License Servers
# Get - License Information
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/license"

#______________________________________________________________________________________
# Storage

# Get - Storage
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storages"

# Post - Data Store Rescan
Invoke-RestMethod -WebSession $SourceServerSession -Method Post -Uri "https://$AppVolServer/cv_api/datastores/rescan"

#______________________________________________________________________________________
# App Volumes Manager Servers

# Get - App Volumes Manager Servers
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/manager_services"

#______________________________________________________________________________________
# Settings

# Get - Settings
Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/settings"
# Settings can be a bit hidden properties in this, as as you go through the nested properties, be sure to do a "| Get-Memeber -force" to see more of the hidden properties the lower down you go. 

