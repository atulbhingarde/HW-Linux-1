#!/bin/bash
#some constants
export RootConst=root
export NotAsRoot=100
export GrpListFile='GroupUser.txt'
export UsrListFile='Users.txt'
export GroupExists=1
export GroupDoesNotExists=0
export UserExists=1
export UserDoesNotExists=0

Check_If_Group_Exist()
{
    GroupNameToCheck=$1
    located=${GroupExists}
    groupNameFound=`awk -F":" -v thisgrp=${GroupNameToCheck} '($1 ~ thisgrp) && (length($1) == length(thisgrp) ) { print $1 }' /etc/group`
    [ "F${groupNameFound}" == "F" ] && located=${GroupDoesNotExists}
    return ${located} 
}
Check_If_User_Exist()
{
    UserNameToCheck=$1
    located=${UserExists}
    userNameFound=`awk -F":" -v thisusr=${UserNameToCheck} '($1 ~ thisusr) && (length($1) == length(thisusr) ) { print $1 }' /etc/passwd`
    [ "F${userNameFound}" == "F" ] && located=${UserDoesNotExists}
    return ${located} 
}
createIt()
 {
#create groups first 
# assumption you are already logged in as a root 
export WhoAmi=`whoami`
if [ "F${WhoAmi}" == "F${RootConst}" ] ; then
    # list required groups and users use them in logic to create group and users add them if the group is not existing
    for GroupName in `cat ${GrpListFile} | col -b | sed "/^$/d" | sed "s/ //g" | sort -u ` ; do
        eval `echo ${GroupName} | awk -F":" '{ sprintf("%s %s\n",$1,$2 ) } END { print  "group="$1 ; print "users="$2} '`
        Check_If_Group_Exist ${group} 
        DoesThisGrpExists=$?
        [ ${DoesThisGrpExists} -eq ${GroupDoesNotExists}  ] && addgroup ${group}
        for ThisUser in `echo ${users} | sed "s/,/ /g" | sort -u` ; do
            Check_If_User_Exist ${ThisUser}  
            ChkStat=$?
            if [ ${ChkStat} -eq ${UserDoesNotExists} ] ; then 
                useradd ${ThisUser} -G ${group}
            else
                usermod -a -G ${group} ${ThisUser}
            fi
        done
    done
else
    echo "Please run the command as ${RootConst}"
    export RetValue=${NotAsRoot}

fi
 }
deleteIt()
 {
#create groups first 
# assumption you are already logged in as a root 
export WhoAmi=`whoami`
if [ "F${WhoAmi}" == "F${RootConst}" ] ; then
    # list required groups and users use them in logic to create group and users add them if the group is not existing
    for GroupName in `cat ${GrpListFile} | col -b | sed "/^$/d" | sed "s/ //g" | sort -u ` ; do
	eval `echo ${GroupName} | awk -F":" '{ sprintf("%s %s\n",$1,$2 ) } END { print  "group="$1 ; print "users="$2} '`
	echo "this is users ${users}"
	echo "this is list of users ${group}"
	for TheseUsers in `echo ${users} | sed "s/,/ /g" | sort -u` ; do
          Check_If_User_Exist ${TheseUsers}  
	  ChkStat=$?
	  [ ${ChkStat} -eq ${UserExists} ] && deluser ${TheseUsers}
	done
	for TheseGroups in `echo ${group} | sed "s/,/ /g" | sort -u | grep -v -E "adm|sudo"` ; do
	  delgroup ${TheseGroups}
	done
    done
else
    echo "Please run the command as ${RootConst}"
    export RetValue=${NotAsRoot}
fi
 }
deleteIt
createIt
echo " students group listed"
members students 
echo " teachers group listed"
members teachers 
echo " adm group listed"
members adm 
echo " sudo group listed"
members sudo 
