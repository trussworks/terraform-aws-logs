package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsLogsConfig(t *testing.T) {
	t.Parallel()

	expectedLogsBucket := fmt.Sprintf("terratest-aws-logs-config-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/config/",
		Vars: map[string]interface{}{
			"region":      awsRegion,
			"logs_bucket": expectedLogsBucket,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	// Empty and delete logs_bucket before terraform destroy
	defer aws.DeleteS3Bucket(t, awsRegion, expectedLogsBucket)
	defer aws.EmptyS3Bucket(t, awsRegion, expectedLogsBucket)
	terraform.InitAndApply(t, terraformOptions)
}
