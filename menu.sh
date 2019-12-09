#!/bin/bash

BUCKET_PRIVATE_SHARE=""
FILE_PRIVATE_SHARE=""
CREATE_BUCKET_NAME=""
PRIVATE_SHARE_BUCKET_NAME_FILE="./tasks/s3/tmp/share_private_bucket_name"
PRIVATE_SHARE_FILE_NAME_FILE="./tasks/s3/tmp/share_private_file_name"
BUCKET_NAME_FILE="./tasks/s3/tmp/bucket_file_name"
PROJECT_FILE="./group_vars/project.ansibled.yml"
## just because PWD includes slashes
PWD_COMMENTED=$(echo "${PWD}" | sed 's/\//\\\//g')
sed -i "s/pwd:[ \/a-zA-Z0-9\._]*/pwd: ${PWD_COMMENTED}/" "${PROJECT_FILE}"

show_menu_create_bucket_name()
{
    echo -n "Bucket name to creat:"
}

show_menu_share_private_dir_name()
{
    echo -n "Bucket name for private share:"
}

show_menu_share_file_name()
{
    echo -n "File name for private share:"
}

ask_share_private_dir_name()
{
    show_menu_share_private_dir_name
    read BUCKET_PRIVATE_SHARE 
    if [ -z "${BUCKET_PRIVATE_SHARE}" ]; then
        echo "share private dir name was not suplied"
        exit 1
    fi
}

ask_share_file_name()
{
    show_menu_share_file_name
    read FILE_PRIVATE_SHARE 
    if [ -z "${FILE_PRIVATE_SHARE}" ]; then
        echo "share file name was not supplied"
        exit 1
    fi
}

ask_create_bucket_name()
{
    show_menu_create_bucket_name
    read CREATE_BUCKET_NAME 
    if [ -z "${CREATE_BUCKET_NAME}" ]; then
        echo "create bucket name was not supplied"
        exit 1
    fi
}

share_private_file_pre_signed_url()
{
    if [ -f "${PRIVATE_SHARE_BUCKET_NAME_FILE}" ]; then
        rm -f "${PRIVATE_SHARE_BUCKET_NAME_FILE}"
    fi
    if [ -f "${PRIVATE_SHARE_FILE_NAME_FILE}" ]; then
        rm -f ${PRIVATE_SHARE_FILE_NAME_FILE} 
    fi

    while true
    do
        ask_share_private_dir_name
        ask_share_file_name
        echo "${BUCKET_PRIVATE_SHARE}" > "${PRIVATE_SHARE_BUCKET_NAME_FILE}" 
        echo "${FILE_PRIVATE_SHARE}" > "${PRIVATE_SHARE_FILE_NAME_FILE}" 
        if [ ! -z "${BUCKET_PRIVATE_SHARE}" ] && [ ! -z "${FILE_PRIVATE_SHARE}" ]; then
            break
        fi
    done

    ## set yml file 
    sed -i "s/task_designated:[ \/a-zA-Z0-9\._]*/task_designated: tasks\/s3\/get_presigned_url\.s3.yml/" "${PROJECT_FILE}"
    ## now we execute ansible playbook
    ansible-playbook -vvv -i hosts.inventory s3.yml --ask-vault-pass
    unlink "${PRIVATE_SHARE_BUCKET_NAME_FILE}" 
    unlink "${PRIVATE_SHARE_FILE_NAME_FILE}" 
}

create_bucket()
{
    if [ -f "${BUCKET_NAME_FILE}" ]; then
        rm -f ${BUCKET_NAME_FILE} 
    fi

    while true
    do
        ask_create_bucket_name
        echo "${CREATE_BUCKET_NAME}" > "${BUCKET_NAME_FILE}" 
        if [ ! -z "${CREATE_BUCKET_NAME}" ]; then
            break
        fi
    done

    ## set yml file 
    sed -i "s/task_designated:[ \/a-zA-Z0-9\._]*/task_designated: tasks\/s3\/create_bucket\.general\.s3.yml/" "${PROJECT_FILE}"
    sed -i "s/bucket_name_create_general:[ \/a-zA-Z0-9\._\-]*/bucket_name_create_general: ${CREATE_BUCKET_NAME}/" "${PROJECT_FILE}"
    ## now we execute ansible playbook
    ansible-playbook -vvv -i hosts.inventory s3.yml --ask-vault-pass
    unlink "${BUCKET_NAME_FILE}" 
}

sed -i "s/pwd:[ \/a-zA-Z0-9\._]*/pwd: ${PWD_COMMENTED}/" "${PROJECT_FILE}"

while true
do
    echo "Select what you want to do:"
    echo "1: share private file with pre signed url"
    echo "2: create bucket"
    echo "q: exit the program"
    read ANS
    if [ "${ANS}" = "q" ]; then
        exit 0
    fi
    if [ ! -z "${ANS}" ]; then
        break 
    fi
done

if [ "${ANS}" = "1" ]; then
    share_private_file_pre_signed_url
elif [ "${ANS}" = "2" ]; then
    create_bucket 
fi

sed -i "s/pwd:[ \/a-zA-Z0-9._]*/pwd: \/tmp/" "${PROJECT_FILE}"
sed -i "s/task_designated:[ \/a-zA-Z0-9\._]*/task_designated: sample\.yml/" "${PROJECT_FILE}"
sed -i "s/bucket_name_create_general:[ \/a-zA-Z0-9\._\-]*/bucket_name_create_general: mybucket/" "${PROJECT_FILE}"

exit 0
