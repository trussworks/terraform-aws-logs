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

func AssertS3BucketPolicyAllowExternalALB(t *testing.T, region string, bucketName string, prefix string, externalAccount string) {
	pattern := fmt.Sprintf(`"Action":"s3:PutObject","Resource":"arn:aws:s3:::%s/%s/AWSLogs/%s/*"`, bucketName, prefix, externalAccount)
	err := AssertS3BucketPolicyContains(t, region, bucketName, pattern)
	require.NoError(t, err)

}

func AssertS3BucketPolicyContains(t *testing.T, region string, bucketName string, pattern string) error {
	policy, err := aws.GetS3BucketPolicyE(t, region, bucketName)
	require.NoError(t, err)

	if !strings.Contains(policy, pattern) {
		return fmt.Errorf("could not find pattern: %s in policy: %s", pattern, policy)
	}

	return nil
}

func TestTerraformAwsLogsAlb(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/alb")
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"vpc_azs":           vpcAzs,
			"test_name":         testName,
			"force_destroy":     true,
			"alb_logs_prefixes": []string{testName},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

func TestTerraformAwsLogsAlbRootPrefix(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/alb")
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"vpc_azs":           vpcAzs,
			"test_name":         testName,
			"force_destroy":     true,
			"alb_logs_prefixes": []string{"", testName},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

func TestTerraformAwsLogsAlbAccount(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/alb_remote")
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"
	externalAlbAccount := "222222222222"
	prefix := "alb"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"vpc_azs":              vpcAzs,
			"alb_external_account": externalAlbAccount,
			"test_name":            testName,
			"force_destroy":        true,
			"alb_logs_prefixes":    []string{prefix},
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
