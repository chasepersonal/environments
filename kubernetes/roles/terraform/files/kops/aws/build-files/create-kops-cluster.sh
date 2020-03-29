TF_OUTPUT=$($HOME/terraform/terraform output -json)
CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .kubernetes_cluster_name.value)"
STATE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_s3_bucket.value)"

kops toolbox template --name ${CLUSTER_NAME} --values <( echo ${TF_OUTPUT}) --template cluster-template.yaml --format-yaml > cluster.yaml

kops create secret --name ${CLUSTER_NAME} -- state ${STATE} --name ${CLUSTER_NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub

kops replace -f cluster.yaml --state ${STATE} --name ${CLUSTER_NAME} --force

kops update cluster --target terraform --state ${STATE} --name ${CLUSTER_NAME} --out .