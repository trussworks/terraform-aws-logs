package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsLogsCloudtrail(t *testing.T) {
	// Note: do not run this test in t.Parallel() mode.
	// Running this test in parallel with other tests in the module
	// often causes issues when attempting to empty and delete the bucket.

	expectedLogsBucket := fmt.Sprintf("terratest-aws-logs-cloudtrail-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/cloudtrail/",
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
