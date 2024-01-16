# Configure Azure Migrate to do dependency analysis on your servers

Now you have successfully set up your [Azure Migrate appliance](azure-migrate.md) and initiated the discovery.  The next step is to ensure that Azure Migrate looks at the servers for Dependency Analysis information to give you the full picture of what is going on within your enviornment. 

To enable this, follow these steps:

* Head over to [https://portal.azure.com](https://portal.azure.com)
* Look for Azure Migrate
* Click on **Discovered items**
* Select your subscription and project where your data will be stored
* You should see a list of your discovered servers
* Click on **Dependency Analysis** and select **Add servers**
* Ensure the right Azure migrate appliance is selected
* Then select all the servers you want dependency analysis to be enabled on
* Click on **Add servers**

🕛 **Data will start to flow, but it's best to leave this feature turned on for at least 24 hours in this lab to get good data to interrogate.**