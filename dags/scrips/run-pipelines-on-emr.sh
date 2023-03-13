#!/bin/bash

export ORCHESTRATION_DIR=/storage/app/compass-orchestration

source ${ORCHESTRATION_DIR}/release/active/scripts/common.sh

PIPELINE_CONFIG_JSON=$1

export FLOW_NAME=$(echo $PIPELINE_CONFIG_JSON | jq -r '.azkabanFlowId')
export PIPELINE_NAME=$(echo $PIPELINE_CONFIG_JSON | jq -r '.pipelineName')
export DESTINATION_SCHEMA=$(echo $PIPELINE_CONFIG_JSON | jq -r '.destinationSchema')
DESTINATION_TABLE=$(echo $PIPELINE_CONFIG_JSON | jq -r '.destinationTable')

STR_EXEC_DATE=$(echo $DB_PARAM_JSON | jq -r '.execDate')
STR_EXEC_TIMESTAMP=$(echo $DB_PARAM_JSON | jq -r '.execTimestamp')
START_DATE=$(echo $DB_PARAM_JSON | jq -r '.startDate')
END_DATE=$(echo $DB_PARAM_JSON | jq -r '.endDate')
LAST_N_DAYS=$(echo $DB_PARAM_JSON | jq -r '.lastNDays')

STR_EXEC_DATE_FRMT=$(echo $STR_EXEC_DATE | tr '-' '_')
export TEMP_DESTINATION_TABLE="${DESTINATION_TABLE}_TMP_${STR_EXEC_DATE_FRMT}"

# ToDo - Determine bucket based on the environment
S3_BUCKET="s3://bi-pipelines-emr-packages-dev" ## Should add -dev per Environment

echo "pipeline_name=${PIPELINE_NAME},
      destination_schema=${DESTINATION_SCHEMA},
      temp_destination_table=${TEMP_DESTINATION_TABLE}"

echo "PIPELINE_DB_PARAMS=${DB_PARAM_JSON}"

export EMR_CLUSTER_ID=`aws emr list-clusters --active --query 'Clusters[0].Id' | tr -d '"'`
export STEP_NAME="BI pipeline "$PIPELINE_NAME
export JOB_CONFS="$S3_BUCKET/job.conf,$S3_BUCKET/log4j.properties"

echo "cluster id=${EMR_CLUSTER_ID}"

echo "Starts Spark job execution"
export EMR_STEP_ID=`aws emr add-steps --cluster-id ${EMR_CLUSTER_ID} \
        --steps "[
                   {
                     \"Args\":[\"spark-submit\",
                       \"--files\", \"$JOB_CONFS\",
                       \"--class\", \"com.admarketplace.datapipeline.core.simple.runner.SimpleJobRunner\",
                       \"--deploy-mode\", \"cluster\",
                       \"--name\", \"$PIPELINE_NAME\",
                       \"--conf\", \"spark.driver.extraJavaOptions=-DFLOW_NAME=$FLOW_NAME\",
                       \"--conf\", \"spark.executor.extraJavaOptions=-DFLOW_NAME=$FLOW_NAME\",
                       \"$S3_BUCKET/amp-reporting-data-aggregation-pipeline.jar\",
                       \"--pipelineName\", \"$PIPELINE_NAME\",
                       \"--job-definition.data-sink.schema\", \"$DESTINATION_SCHEMA\",
                       \"--job-definition.data-sink.table\", \"$TEMP_DESTINATION_TABLE\",
                       \"--db.param.execDate\", \"$STR_EXEC_DATE\",
                       \"--db.param.execTimestamp\", \"$STR_EXEC_TIMESTAMP\",
                       \"--db.param.startDate\", \"$START_DATE\",
                       \"--db.param.endDate\", \"$END_DATE\",
                       \"--db.param.lastNDays\", \"$LAST_N_DAYS\"
                     ], \
                     \"Type\":\"CUSTOM_JAR\",
                     \"ActionOnFailure\":\"CONTINUE\",
                     \"Jar\":\"command-runner.jar\",
                     \"Properties\":\"\",\"Name\":\"$STEP_NAME\"
                   }
                 ]" --query 'StepIds[0]' | tr -d '"'`

echo "emr_step_id =${EMR_STEP_ID}"

export STEP_FINISHED_FLAG=false

while [ $STEP_FINISHED_FLAG = false ]
do
   echo "sleeping 10 seconds"
   export EMR_STEP_STATUS=`aws emr list-steps --cluster-id ${EMR_CLUSTER_ID} --step-id ${EMR_STEP_ID} --query  'Steps[0].Status.State' | tr -d '"'`
   echo "EMR_STEP_STATUS ${EMR_STEP_STATUS}"
   sleep 10
   echo "step_finished ${STEP_FINISHED_FLAG}"


   declare -a flag_true=("COMPLETED" "CANCELLED" "INTERRUPTED") 
   declare -a flag_false=("PENDING" "CANCEL_PENDING" "RUNNING") 
   declare -a failed_flag_true=("FAILED") 
   if [[ " ${flag_true[*]} " == *${EMR_STEP_STATUS}* ]]; then
     STEP_FINISHED_FLAG=true
     echo "step_finished ${STEP_FINISHED_FLAG}"
   elif [[ " ${flag_false[*]} " == *${EMR_STEP_STATUS}* ]]; then
     STEP_FINISHED_FLAG=false
     echo "step_finished ${STEP_FINISHED_FLAG}"
   elif [[ " ${failed_flag_true[*]} " == *${EMR_STEP_STATUS}* ]]; then
     EMR_STEP_ERR_OUT=`aws emr describe-step --cluster-id ${EMR_CLUSTER_ID} --step-id ${EMR_STEP_ID} --query 'Step.Status.FailureDetails' | tr -d '{\n' | tr -d '}'`
     echo "step error output = ${EMR_STEP_ERR_OUT}"
     echo "step_finished ${STEP_FINISHED_FLAG}"
     exit 1
   fi


done

echo "Finish Spark job execution"