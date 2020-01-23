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

	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	// AWS only supports one configuration recorder per region.
	// Each test using aws-config will need to specify a different region.
	awsRegion := "us-east-2"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/config/",
		Vars: map[string]interface{}{
			"region":        awsRegion,
			"test_name":     testName,
			"force_destroy": true,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	// Empty and delete logs_bucket before terraform destroy
	defer aws.DeleteS3Bucket(t, awsRegion, testName)
	defer aws.EmptyS3Bucket(t, awsRegion, testName)
	terraform.InitAndApply(t, terraformOptions)
}
