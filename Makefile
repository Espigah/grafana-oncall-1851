format:
	terraform fmt -recursive

clear:
	find . -name '.terraform' -type d -prune -print -exec rm -rf '{}' \;
	find . -name 'terraform.tfstate' -prune -print -exec rm -rf '{}' \;
	find . -name '.terraform.*' -prune -print -exec rm -rf '{}' \;


init:
	terraform init

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

up:
	@echo "Starting docker-compose" 
	@docker-compose up -d --build --remove-orphans

setup:
	sudo chmod 775 -R __tools__/grafana/plugins/
	@make init --no-print-directory

@PHONY: up init apply destroy clear format