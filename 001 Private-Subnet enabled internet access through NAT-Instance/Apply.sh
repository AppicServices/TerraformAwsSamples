#!/bin/bash

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# connect through aws-vault profile
#
# You have to modifiy this to work in your environment. In my case MFA is activated. This is necessary if you want to modifiy IAM.
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
aws-vault exec tf_experimental -- terraform apply