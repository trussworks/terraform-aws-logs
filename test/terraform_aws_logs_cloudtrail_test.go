package test

/*
import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestTerraformAwsLogsCloudtrail(t *testing.T) {
	// Note: do not run this test in t.Parallel() mode. because the
	// Cloudtrail module doesn't support running multiple instances

	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/cloudtrail")
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"test_name":              testName,
			"force_destroy":          true,
			"cloudtrail_logs_prefix": testName,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

func TestTerraformAwsLogsCloudtrailRootPrefix(t *testing.T) {
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/cloudtrail")
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"test_name":              testName,
			"force_destroy":          true,
			"cloudtrail_logs_prefix": "",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
*/
