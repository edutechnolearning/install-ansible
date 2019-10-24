#!/bin/bash
# Copy Write: edutechnolearning@gmail.com, info@smarttechfunda.com
# This script install the ansible and test it on remote instance.

exit_script(){
    exit $1
}

check_sshd_service(){
   sudo systemctl status sshd > /dev/null
   if [ $? -ne 0 ];then
       echo "The sshd service is not running. Start the the sshd service and re-run the script."
       exit_script 1
   fi
}

check_prerequisite(){
    python3 -V
    if [ $? -ne 0 ];then
        echo "Python3 is not installed. Intall the python3 and re-run the script."
        exit_script 1
    fi

    rpm -qi python3-pip
    if [ $? -ne 0 ];then
       echo "Python3-pip is not installed. Intall the python3-pip and re-run the script."
       exit_script 1
    fi
    check_sshd_service
}

install_ansible(){
   pip3 install ansible --user
   if [ $? -eq 0 ];then
       echo "Successfully installed the ansible."
   else
       echo "Failed to installed the ansible."
   fi
}

create_copy_key(){
    ssh-keygen
    ssh-copy-id  $user_name@$remote_ip
    if [ $? -ne 0 ];then
        echo "Failed to copy the key."
        echo "Check the sshd service of the $remote_ip instance."
        echo "Run the command 'ssh-copy-id  $user_name@$remote_ip' manually to copy the key."
        exit_script 1
    fi
}

test_ansible(){
    while(true)
    do
        echo "Do you want to test the ansible? [Y/N]: "
        read status
        if [ "$status" = "Y" ];then
            echo "Enter the remote instance IP to test ansible."
            echo "Make sure sshd service is running on remote instance."
            read remote_ip
            echo "Enter the username to login to the remote instance:"
            read user_name
            sudo mkdir /etc/ansible
            if [ $? -ne 0 ];then
                echo "Failed to create the /etc/ansible directory."
                exit_script 1
            fi

            sudo touch /etc/ansible/hosts
            if [ $? -ne 0 ];then
                echo "Faile to create the hosts file on the path /etc/ansible."
                exit_script 1
            fi
            sudo chmod 666 /etc/ansible/hosts
            sudo echo "[test]" > /etc/ansible/hosts
            sudo echo "192.168.0.104" >> /etc/ansible/hosts
            sudo chmod 644 /etc/ansible/hosts
            login_user=`whoami`
            if [ -d "/home/$login_user/.ssh" ];then
                echo "/home/$login_user/.ssh folder already exist."
                while(true)
                do
                    echo "Do you wish to continue to overwrite [Y/N]: "
                    read login_user_status
                    if [ "$login_user_status" = "Y" ];then
                        create_copy_key
                        ansible -i /etc/ansible/hosts test -m ping
                    else
                        echo "If you want to test the ansible then check the following URL for manual step 7."
                        echo ""
                        exit_script 0
                    fi
                done
            else
                create_copy_key
                ansible -i /etc/ansible/hosts test -m ping
            fi
            exit_script 0
        elif [ "$status" = "N" ];then
            echo "The ansible is installed."
            echo "If you want to test the ansible then check the following URL for manual step 4."
            echo ""
            exit_script 0
        else
            echo "Enter the correct option [Y/N]: "
        fi
    done
}


####Main####

check_prerequisite
install_ansible
test_ansible
