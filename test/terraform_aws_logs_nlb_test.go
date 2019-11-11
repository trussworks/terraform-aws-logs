package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsLogsNlb(t *testing.T) {
	t.Parallel()

	expectedLogsBucket := fmt.Sprintf("terratest-aws-logs-nlb-%s", strings.ToLower(random.UniqueId()))
	vpcName := fmt.Sprintf("terratest-vpc-nlb-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/nlb/",
		Vars: map[string]interface{}{
			"region":      awsRegion,
			"vpc_azs":     vpcAzs,
			"logs_bucket": expectedLogsBucket,
			"vpc_name":    vpcName,
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
