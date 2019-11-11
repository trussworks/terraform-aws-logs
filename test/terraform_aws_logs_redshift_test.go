package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsLogsRedshift(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping test in short mode.")
	}

	t.Parallel()

	expectedLogsBucket := fmt.Sprintf("terratest-aws-logs-redshift-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/redshift/",
		Vars: map[string]interface{}{
			"region":      awsRegion,
			"logs_bucket": expectedLogsBucket,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	// Empty logs_bucket before terraform destroy
	defer aws.EmptyS3Bucket(t, awsRegion, expectedLogsBucket)
	terraform.InitAndApply(t, terraformOptions)
}
