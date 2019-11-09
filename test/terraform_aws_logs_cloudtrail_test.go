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
	t.Parallel()

	expectedLogsBucket := fmt.Sprintf("terratest-aws-logs-cloudtrail-%s", strings.ToLower(random.UniqueId()))
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

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
	terraform.InitAndApply(t, terraformOptions)

	// Empty logs_bucket before terraform destroy
	aws.EmptyS3Bucket(t, awsRegion, expectedLogsBucket)
}
