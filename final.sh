
#############################################################################################################################################################################
#         																			            #	
#  * Please Remember That You'll Need To Have Permissions To Check Roles/Policy, This is the same Policy Used By ECS EXEC Executor
#     {
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Effect": "Allow",
#            "Action": [
#                "iam:GetInstanceProfile",
#                "iam:SimulatePrincipalPolicy",
#                "ec2:DescribeSubnets",
#                "ec2:DescribeVpcEndpoints",
#                "ecs:DescribeClusters",
#                "ecs:DescribeContainerInstances",
#                "ecs:DescribeTaskDefinition",
#                "ecs:DescribeTasks"
#            ],
#            "Resource": "*"
#        }
#    }
# }			                  					                                                                        		     #
#  * Right Now Windows Support Is In Testing, Looking For Volunteer To Test							        		                     #
#  * Yes It Got Exdened By Few Lines But Will Optimise In Next Revision 						    						     #
#  * The Python Copy Of This Is Still In Process, Will Update Once Done           				           						     #
#  * Please Provide Feedback On The Quip, What Can Be Done And What Can Be Removed To Optimise         							        	    #
#  * Please Note That Once Your Provide Cluster ARN, Don't Forget To Add Service Name To It	       								             #
#	Example :  arn:aws:ecs:us-east-1:022XXXXXX:cluster/support   <=== Add Service To Arn i.e  arn:aws:ecs:us-east-1:022XXXXXX:cluster/support/<service_name>    	    #
##############################################################################################################################################################################


#!/bin/bash
echo "=================================================================================================================================================================="
echo "                                                         Created By Aanand Kumar With ♥️                                                              "
echo "=================================================================================================================================================================="

#Defined Global variable

redhat=$(cat /etc/os-release | grep -E '^ID=' | awk -F ['='] '{print $2}')
ubuntu=$(cat /etc/os-release | grep -E '^ID=' | awk -F ['='] '{print $2}')
jq=/usr/bin/jq
unzip=/usr/bin/jq 
cli=$HOME/.aws/credentials

#Checking For Pre-Requisits Specific Specific OS For JQ and Unzip
function jq_linux_rpm(){
sudo yum install jq unzip -y 
} 

function jq_linux_deb(){
sudo apt-get install jq unzip -y
}

function jq_mac(){
brew install jq -y
brew install unzip -y
}

#Checking if AWS-CLI Installed or not

#AWS CLI For Windows
function aws_cli_windows()
{
curl "https://awscli.amazonaws.com/AWSCLIV2.msi" -o AWSCLIV2.msi
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
}

#AWS CLI For MAC

function aws_cli_mac() 
{
aws
if [ $? -gt 0 ]; then
  echo "==============================================AWS CLI Not Is Installed, Installing..============================================================"
  curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
  sudo installer -pkg AWSCLIV2.pkg -target /
  curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
  sudo installer -pkg ./AWSCLIV2.pkg -target /
  echo "Installation Done"
else
  echo "AWS CLI Is Already Installed Skipping"
fi
}

#Creating Function For Linux 

function aws_cli_linux() 
 {
AWS_CLI_Path=/usr/bin/aws
AWS_CLI_Path_Local=/usr/local/bin/aws
if [ -f "$AWS_CLI_Path" ]; then
   echo "===================================================AWS CLI Is Installed :  ✅===================================================================="
elif [ -f "$AWS_CLI_Path_Local" ]; then
   echo "===================================================AWS CLI Is Installed :  ✅===================================================================="
#  echo "AWS CLI Is Installed But Seems On Local Creating Symbolic Link : �✅" #ignore 
   ln -s /usr/local/bin/aws /usr/bin/aws
else
   echo "AWS CLI Not Found Downloading And Installing"
   read -p "Now I'll Install CLI For You, Are You Ready(Y/N) ? " REPLY
   if [[ "$REPLY" != "${REPLY#[Yy]}" ]];
   then
     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
     unzip awscliv2.zip
     sudo ./aws/install
  else
    echo "Exiting!! Please Choose Y/y To Continue"
    exit 1
  fi
fi
}

#Looking For The Session Manager Linux

function session_manager_rpm()
{

SESSION_MANAGER=/usr/bin/session-manager-plugin
SESSION_MANAGER1=/usr/local/bin/session-manager-plugin

echo "Checking For Session Manager Plugin: 💤"
if [ -f "$SESSION_MANAGER" ]; then
   echo "=================================================Session Manager Is Installed : ✅================================================================="
elif [ -f "$SESSION_MANAGER1" ]; then
   echo "=================================================Session Manager Is Installed :  ✅================================================================"
   ln -s /usr/local/bin/session-manager-plugin /usr/bin/session-manager-plugin
else
   curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
   sudo yum install -y session-manager-plugin.rpm
   echo "Installation Done : ✅"
fi
}

function session_manager_deb(){

SESSION_MANAGER=/usr/bin/session-manager-plugin
SESSION_MANAGER1=/usr/local/bin/session-manager-plugin

echo "Checking For Session Manager : 💤"
if [ -f "$SESSION_MANAGER" ]; then
   echo "=================================================Session Manager Is Installed : ✅============================================================="
elif [ -f "$SESSION_MANAGER1" ]; then
   echo "=================================================Session Manager Is Installed : ✅============================================================="
   ln -s /usr/local/bin/session-manager-plugin /usr/bin/session-manager-plugin
else
   curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
   sudo dpkg -i session-manager-plugin.deb
   echo "Installation Done :   ^|^e"
fi
}

#Session Manager For MAC

function session_manager_mac()
{
SESSION_MANAGER=/usr/local/bin/session-manager-plugin
echo "Checking For Session Manager: 💤"
if [ -f "$SESSION_MANAGER" ]; then
   echo "====Session Manager Is Installed==== :   ^|^e"
else
   curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
   unzip sessionmanager-bundle.zip
   sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
   echo "Installation Done :   ^|^e"
fi
}

#Session Manager For Windows

function session_manager_windows() 
 {
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe" -o SessionManagerPluginSetup.exe
SessionManagerPluginSetup.exe
}

#Calling AWS CLI As Per Os Type

if [ "$(uname)" == "Darwin" ]; then
echo ""
echo "Checking For Pre-Requists : 🚨"
echo ""
  if [ -z $jq ] && [ -z $unzip ]; then
  jq_mac
  else 
  echo "JQ And Unzip Is Already Installed:  ✅"
  fi
  aws_cli_mac
  ession_manager_mac
elif [ $redhat == "rhel" ]; then
echo ""
echo "Checking For Pre-Requists : 🚨"
echo ""
  if [ -z $jq ] && [ -z $unzip ]; then
  jq_linux_rpm
  else 
  echo "JQ And Unzip Is Already Installed:  ✅"
  fi
  aws_cli_linux
  session_manager_rpm
elif [ $ubuntu == "ubuntu" ]; then
echo ""
echo "Checking For Pre-Requists : 🚨"
echo ""
  if [ -z $jq ] && [ -z $unzip ]; then
  jq_linux_rpm
  else 
  echo "JQ And Unzip Is Already Installed ✅"
  fi
aws_cli_linux
session_manager_deb
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
  aws_cli_windows
  session_manager_windows
fi

#Looking for the Require Roles
echo "Checking The Role : 🚨"

echo "========================================================== Checking For Roles & Permissions ==============================================================="
echo ""
aws sts get-caller-identity
if [ $? == 0 ]; then
  echo "Role/User Found, Checking For Required Permission In Next Step : ✅"
else
  echo "No Role Or Config Is Provided : ❌	"
  read -p "So Do You Want Me To Configure AWS CLI For You(Y/N) ? " Config
  if [[ "$Config" != "${Config#[Yy]}" ]]; then
     function cli_input() {
     read -p "Please Enter AWS_ACCESS_KEY: " AWS_ACCESS_KEY
     read -p "Please Enter AWS_SECRET_KEY: " AWS_SECRET_KEY
     }
     function cli_embed() {
     mkdir -p $HOME/.aws
     echo "
         [default]
         aws_access_key_id = $AWS_ACCESS_KEY
         aws_secret_access_key = $AWS_SECRET_KEY
        " > $HOME/.aws/credentials
        }
      cli_input
      if [ -z $AWS_ACCESS_KEY ] || [ -z $AWS_SECRET_KEY ]; then
        while [ -z $AWS_ACCESS_KEY ] || [ -z $AWS_SECRET_KEY ]; do
        cli_input
        echo "Values Can't Be Empty! Please Retry Again : ❌"
        done
      else
       cli_embed
      fi
  else
    echo "So You Want To Proceed With Role ! Great, Please Attach Role And Retry!!"
    exit
  fi 
fi

#Checking If User Have Required Permission To Create Role And RunTas And UpdateService 

user_or_role=$(aws sts get-caller-identity | awk -F [':'] '/Arn/ {print $4}')
role_for_role=$(aws sts get-caller-identity | awk -F ['/'] '/Arn/ {print $2}')
role_for_user=$(aws sts get-caller-identity | awk -F ['/'] '/Arn/ {print $2}' | rev | cut -c2- | rev)
account_id=$(aws sts get-caller-identity | awk -F [':'] '/Arn/ {print $6}')

if [ $user_or_role == 'sts' ]; then
   user_permission=$(aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::$account_id:role/$role_for_role --action-names ecs:UpdateService ecs:RunTask ecs:DescribeService iam:CreatePolicy --output json | jq -r '.EvaluationResults[].EvalDecision' | grep -i implicitDeny -c) 
   if [ $user_permission -gt 0 ]; then
   echo "Role 🚨 $role_for_role 🚨  Doesn't Have Permission To Create SSM/Task/UpdateService! Exiting : ❌"
   exit 
   else
   echo ""
   echo "Role 🚨 $role_for_role 🚨 Have Permission To Create SSM/Task/UpdateService :  ✅"
   echo ""
   fi
elif [ $user_or_role == 'iam' ]; then
   user_permission=$(aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::$account_id:user/$role_for_user --action-names ecs:UpdateService ecs:RunTask ecs:DescribeService iam:CreatePolicy --output json | jq -r '.EvaluationResults[].EvalDecision' | grep -i implicitDeny -c)
   if [ $user_permission -gt 0 ]; then
   echo "User 🚨 $role_for_user 🚨 Doesn't Have Permission To Create SSM/Task/UpdateService! Exiting : ❌"
   exit 
   else
   echo ""
   echo "User 🚨 $role_for_user 🚨 Have Permission To Create SSM/Task/UpdateService :  ✅"
   fi
else
   echo "Something Went Wrong!!! : ❌"
   exit 
fi

#CLI Setup Done, Now Will Create Policy
echo ""
echo "I'm Creating Required IAM Policy For You, Created....100% :  ✅"
cat <<< '{
   "Version": "2012-10-17",
   "Statement": [
       {
       "Effect": "Allow",
       "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
       ],
      "Resource": "*"
      }
   ]
}
' > policy.json

#Policy Document Created, Below Are Steps To Create Policy And Will Attach To Role

POLICY_ARN=$(aws iam create-policy --policy-name ECS-EXEC-Delete-MePlz_$(date +"%s") --policy-document file://policy.json | jq .Policy.Arn |  tr -d '"' )
echo ""
echo "Policy Created And Fetched Policy ARN, Now Will Add To Task Role : ✅"
echo "======================================================================================================================================================================="
echo ""
function role_no_input()
{
  read -p "Please Enter Your Task Role Name: " ROLE_NAME
}

#Above Created policy Will Be Added To Role
function role_input()
{
  aws iam attach-role-policy --policy-arn $POLICY_ARN --role-name $ROLE_NAME
  echo "" 
  echo "SSM Policy Added To Task Role :  ✅"
}
#Calling Function And Checking For Non-Empty Value

echo "====================================================  Checking ECS EXEC For Service & Task ==========================================================================="
echo "============================================== Note : Don't Forget To Add Service In Cluster Arn ====================================================================="
role_no_input
if [ -z $ROLE_NAME ]; then
  while [ -z $ROLE_NAME ]; do
  echo ""
  echo "All Fields Are Mendatory And Can't Be Left Blank : 🚨"
  role_no_input
  done
else
  role_input
fi


#Fetching Basics Details To Start Task/Update Service With EXEC.
echo ""
read -p "So Do You Want Enable ECS EXEC On Your Service(Y/N) ? " SER_VALUE
if [[ "$SER_VALUE" != "${SER_VALUE#[Yy]}" ]]; then
echo ""
echo "Checking If Your Service Have ECS EXEC Enabled, Please Provide Cluster Arn + Service Name From Console Or CLI : 🚨"
     echo ""
     echo "Example :  arn:aws:ecs:us-east-1:022XXXXXX:cluster/support   <=== Add Service To Arn i.e  arn:aws:ecs:us-east-1:022XXXXXX:cluster/support/<service_name>"
     echo ""
     read -p "Please Enter Your Clutser ARN With Service Name : " cluster_arn
     C_NAME=$(echo $cluster_arn | awk -F ['/'] '{print $2}')
     S_NAME=$(echo $cluster_arn | awk -F ['/'] '{print $3}')
     REGION=$(echo $cluster_arn | awk -F [':'] '{print $4}')
     T_DEFINITION=$(aws ecs describe-services --cluster $C_NAME --service $S_NAME | jq -r '.services[].deployments[].taskDefinition' | awk -F ['/'] '{print $2}') 
     Container=$(aws ecs describe-tasks --tasks $(aws ecs list-tasks --service $S_NAME --cluster $C_NAME | jq -r '.taskArns[]' | head -1 | awk -F ['/'] '{print $3}') --cluster $C_NAME | jq -r '.tasks[].containers[].name')
#     read -p "Enter Your Service Name: " S_NAME
#     read -p "Enter Your Cluster Name: " C_NAME
#     read -p "Enter Your Region Please: " REGION
#     read -p "Enter Your Task Defintion: " T_DEFINITION
#     read -p "Enter Container Name: " Container

#Forcing User To Not To Fill Any Non-Empty Value
#     while [ -z $S_NAME ] || [ -z $C_NAME ] || [ -z $REGION ] || [ -z $T_DEFINITION ]; do
     while [ -z $cluster_arn ]; do
      echo "Values Can't Be Empty!!"
      read -p "Cluster Arn Please: " cluster_arn
#     read -p "Enter Your Service Name: " S_NAME
#     read -p "Enter Your Cluster Name: " C_NAME
#     read -p "Enter Your Region Please: " REGION
#     read -p "Enter Your Task Defintion: " T_DEFINITION
#     read -p "Enter Container Name: " Container
     done

#Describing Service To Check If Execute Command Enabled Or Not, If Not Updating Service With Enable Execute.
     EXEC_STATUS=$(aws ecs describe-services --service $S_NAME --cluster $C_NAME  --region $REGION | jq .services[].enableExecuteCommand)
     if [ "$EXEC_STATUS" == "false" ]; then
       echo "" 
       echo "ECS Exec Not Enabled At Your Service Level: ❌ " 
       read -p "So You Want To Update Your Service(Y/N) ? " SERVICE
       if [[ "$SERVICE" != "${SERVICE#[Yy]}" ]];
         then
           echo "Updating Your Service $S_NAME..."
           SERVICE_UPDATE=$(aws ecs update-service --service $S_NAME --enable-execute-command --task-definition $T_DEFINITION --cluster $C_NAME --force-new-deployment --region $REGION)
           sleep 40s

#Checking If Service Have Reached Steady State

           #STEADY_STATE=$(aws ecs describe-services --service $S_NAME --cluster $C_NAME | jq .services | jq .[].events | jq -r .[].message | head -1 | awk '{print $6}')
           while [ "$(aws ecs describe-services --service $S_NAME --cluster $C_NAME | jq .services | jq .[].events | jq -r .[].message | head -1 | awk '{print $6}')" != "steady" ]; do
           echo "Waiting For Service $S_NAME To Get Steady State : 💤 "
           sleep 10s
           done

#Once Service Is Steady, Will Fetch Task Id And Do EXEC
           echo ""
           echo "Service $S_NAME Is Stable Now, Fetching Task And Checking If ESC EXEC Is Running: ✅ "
           TASK_ID=$(aws ecs list-tasks --service $S_NAME --cluster $C_NAME | jq -r .taskArns[] | cut -c 49- | tail -1)
           function task_id_service()
           {
           aws ecs execute-command  \
           --region $REGION \
           --cluster $C_NAME \
           --task $TASK_ID \
           --container $Container \
           --command "/bin/bash" \
           --interactive
          }
          #From Above Function Fetched The Task Id No Describing To See If Task Is Running Or Not.

          #TASK_STATE=$(aws ecs describe-tasks --tasks $TASK_ID --cluster $C_NAME |  jq .tasks | jq .[].containers | jq -r .[].managedAgents | jq -r .[].lastStatus)
          #echo $TASK_STATE
          #echo $TASK_ID

          while [ "$(aws ecs describe-tasks --tasks $TASK_ID --cluster $C_NAME |  jq .tasks | jq .[].containers | jq -r .[].managedAgents | jq -r .[].lastStatus)" != "RUNNING" ]; do 
          #TASK_STATE=$(aws ecs describe-tasks --tasks $TASK_ID --cluster $C_NAME |  jq .tasks | jq .[].containers | jq -r .[].managedAgents | jq -r .[].lastStatus)
          echo "Agent Not Ready Yet, Still Waiting Task To Come Online : 💤"
          sleep 10s
          done
          echo "Task Come Into Running State, Starting ECS EXEC ✅"
          task_id_service
          #Created Execute Function For ECS Exec With All Above Information
       else
         echo "Great We Can Test With StandAlone Task Please Provide Below Details : ⬇️ "
         echo "For Info Please Visit : https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_RunTask.html"
         read -p "Enter Your Task Defintion: " T_DEFINITION
         read -p "Enter Your Security Group: " S_Group
         read -p "Enter Your Subnet: "     SUBNET
         read -p "Enter Container Name: "  Container
         read -p "Can You Confirm If You Are In Private Subnet(Y/N)?: " INTERNET

#Checking If Task Is In Public Or Private Subnet So I Can Enable Public Ip Enable/Disabled

           if [[ "$INTERNET" != "${INTERNET#[Yy]}" ]]; then
              TASK=$(aws ecs run-task \
              --cluster $C_NAME   \
              --task-definition $T_DEFINITION \
              --network-configuration awsvpcConfiguration="{subnets=$SUBNET,securityGroups=$S_Group,assignPublicIp=DISABLED}" \
              --enable-execute-command \
              --launch-type FARGATE \
              --region $REGION |  jq .tasks | jq .[].containers | jq -r .[].taskArn | cut -c 49-)
              echo "All Set, Checking For EXEC Agent To Come Online.."
              sleep 5s
              #TASK_STATE=$(aws ecs describe-tasks --tasks $TASK --cluster $C_NAME |  jq .tasks | jq .[].containers | jq -r .[].managedAgents | jq -r .[].lastStatus)
              while [ "$(aws ecs describe-tasks --tasks $TASK --cluster $C_NAME |  jq .tasks | jq .[].containers | jq -r .[].managedAgents | jq -r .[].lastStatus)" != "RUNNING" ]; do 
                echo "Agent Not Ready, Still Waiting Task To Come Online"
              sleep 10s
              done
              echo "Task Started, Doing ECS Exec On Your Task $TASK | ✅"
      	      aws ecs execute-command  \
              --region $REGION \
              --cluster $C_NAME \
              --task $TASK \
              --container $Container \
              --command "/bin/bash" \
              --interactive
           else
              TASK=$(aws ecs run-task \
              --cluster $C_NAME   \
              --task-definition $T_DEFINITION \
              --network-configuration awsvpcConfiguration="{subnets=$SUBNET,securityGroups=$S_Group,assignPublicIp=ENABLED}" \
              --enable-execute-command \
              --launch-type FARGATE \
              --region $REGION | jq .tasks | jq .[].containers | jq -r .[].taskArn | cut -c 49-)
             echo "All Set, Checking For EXEC Agent To Come Online.."
             sleep 5s
             while [ $(aws ecs describe-tasks --tasks $TASK --cluster $C_NAME |  jq .tasks | jq .[].containers | jq -r .[].managedAgents | jq -r .[].lastStatus) != "RUNNING" ]; do 
               echo "Agent Is Not Ready Yet, Still Waiting Task To Come Online"
               sleep 10s
             done
             echo "Task Started, Doing ECS Exec On Your Task $TASK : ✅"
             aws ecs execute-command  \
             --region $REGION \
             --cluster $C_NAME \
             --task $TASK \
             --container $Container \
             --command "/bin/bash" \
             --interactive
         fi
      fi
  else
    echo "Your Service Is Already Enabled With ECS Exec, Going Insided Your Container Now : ✅ "
    TASK_ID=$(aws ecs list-tasks --service $S_NAME --cluster $C_NAME | jq -r .taskArns[] | cut -c 49- | head -1)
    aws ecs execute-command  \
           --region $REGION \
           --cluster $C_NAME \
           --task $TASK_ID \
           --container $Container \
           --command "/bin/bash" \
           --interactive
  fi
else
   echo "Great We Can Test With StandAlone Task Please Provide Below Details:  ⬇️ "
         read -p "Enter Your Task Defintion: " T_DEFINITION
         read -p "Enter Your Security Group: " S_Group
         read -p "Enter Your Subnet: "     SUBNET
         read -p "Enter Your Region: "     REGION
         read -p "Enter Your Cluster: "    C_NAME
         read -p "Enter Container Name: "  Container 
         read -p "Can You Confirm If You Are In Private Subnet(Y/N)?: " INTERNET
            if [[ "$INTERNET" != "${INTERNET#[Yy]}" ]]; then
              TASK=$(aws ecs run-task \
              --cluster $C_NAME   \
              --task-definition $T_DEFINITION \
              --network-configuration awsvpcConfiguration="{subnets=$SUBNET,securityGroups=$S_Group,assignPublicIp=DISABLED}" \
              --enable-execute-command \
              --launch-type FARGATE \
              --region $REGION |  jq .tasks | jq .[].containers | jq -r .[].taskArn | cut -c 49-)
              echo "All Set, Checking For EXEC Agent To Come Online.. : 💤"
              sleep 5s
              #TASK_STATE=$(aws ecs describe-tasks --tasks $TASK --cluster $C_NAME |  jq .tasks | jq .[].containers | jq -r .[].managedAgents | jq -r .[].lastStatus)
              while [ "$(aws ecs describe-tasks --tasks $TASK --cluster $C_NAME |  jq .tasks | jq .[].containers | jq -r .[].managedAgents | jq -r .[].lastStatus)" != "RUNNING" ]; do 
                echo "Agent Not Ready, Still Waiting Task To Come Online : 💤"
                sleep 10s
              done
              echo "Task Started, Doing ECS Exec On Your Task $TASK |  ✅"
              aws ecs execute-command  \
              --region $REGION \
              --cluster $C_NAME \
              --task $TASK \
              --container $Container \
              --command "/bin/bash" \
              --interactive
           else
              TASK=$(aws ecs run-task \
              --cluster $C_NAME   \
              --task-definition $T_DEFINITION \
              --network-configuration awsvpcConfiguration="{subnets=$SUBNET,securityGroups=$S_Group,assignPublicIp=ENABLED}" \
              --enable-execute-command \
              --launch-type FARGATE \
              --region $REGION | jq .tasks | jq .[].containers | jq -r .[].taskArn | cut -c 49-)
             echo "All Set, Checking For EXEC Agent To Come Online..: 💤"
             sleep 5s
             while [ $(aws ecs describe-tasks --tasks $TASK --cluster $C_NAME |  jq .tasks | jq .[].containers | jq -r .[].managedAgents | jq -r .[].lastStatus) != "RUNNING" ]; do 
               echo "Agent Is Not Ready Yet, Still Waiting Task - $TASK To Come Online : 💤"
               sleep 10s
             done
             echo "Agent Available Now, Doing ECS Exec On Your Task $TASK :  ✅"
             aws ecs execute-command  \
             --region $REGION \
             --cluster $C_NAME \
             --task $TASK \
             --container $Container \
             --command "/bin/bash" \
             --interactive
         fi
     fi

#Thank You But This Is Already 400+ Lines Of Code, Don't Want To Extend It More.
