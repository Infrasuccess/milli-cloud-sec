TF_DIR=terraform
EMAIL?=your_email@example.com

tf-init:
	terraform -chdir=$(TF_DIR) init -reconfigure -input=false

tf-fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

tf-validate:
	terraform -chdir=$(TF_DIR) validate

tf-plan:
	terraform -chdir=$(TF_DIR) plan -input=false -var="notification_email=$(EMAIL)"

tf-apply:
	terraform -chdir=$(TF_DIR) apply -input=false -auto-approve -var="notification_email=$(EMAIL)"

tf-destroy:
	terraform -chdir=$(TF_DIR) destroy -input=false -auto-approve -var="notification_email=$(EMAIL)"