package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

func AssertS3BucketPolicyAllowExternalNLB(t *testing.T, region string, bucketName string, prefix string, externalAccount string) {
	pattern := fmt.Sprintf(`"Action":"s3:PutObject","Resource":"arn:aws:s3:::%s/%s/AWSLogs/%s/*"`, bucketName, prefix, externalAccount)
	err := AssertS3BucketPolicyContains(t, region, bucketName, pattern)
	require.NoError(t, err)

}

func TestTerraformAwsLogsNlb(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/nlb")
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":            awsRegion,
			"vpc_azs":           vpcAzs,
			"test_name":         testName,
			"force_destroy":     true,
			"nlb_logs_prefixes": []string{testName},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

func TestTerraformAwsLogsNlbRootPrefix(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/nlb")
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":            awsRegion,
			"vpc_azs":           vpcAzs,
			"test_name":         testName,
			"force_destroy":     true,
			"nlb_logs_prefixes": []string{"", testName},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

func TestTerraformAwsLogsNlbAccount(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/nlb_remote")
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"
	externalAlbAccount := "222222222222"
	prefix := "nlb"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":               awsRegion,
			"vpc_azs":              vpcAzs,
			"nlb_external_account": externalAlbAccount,
			"test_name":            testName,
			"force_destroy":        true,
			"nlb_logs_prefixes":    []string{prefix},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// let us check to make sure the resource contains the alb_account
	AssertS3BucketPolicyAllowExternalALB(t, awsRegion, testName, prefix, externalAlbAccount)
}
