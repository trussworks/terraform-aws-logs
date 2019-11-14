package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsLogsElb(t *testing.T) {
	t.Parallel()

	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/elb/",
		Vars: map[string]interface{}{
			"region":    awsRegion,
			"vpc_azs":   vpcAzs,
			"test_name": testName,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	// Empty logs_bucket before terraform destroy
	defer aws.EmptyS3Bucket(t, awsRegion, testName)
	terraform.InitAndApply(t, terraformOptions)
}
