# # import os, shutil, subprocess, json, base64, boto3
# import os, shutil, subprocess, json, base64
# # from python_terraform import Terraform

# github_event = None
# repo = None
# name = None
# # email = None

# # def aws_check():
# #     sts_client = boto3.client('sts')
# #     response = sts_client.get_caller_identity()
# #     print('AWS Identity: ', response)

# def provision_runners():
#     print('Provisioning self-hosted runners...')

#     # Set the path to include the custom layer binaries
#     # os.environ['PATH'] = '/opt/bin:' + os.environ['PATH']
#     # Set the SSH key path
#     # ssh_key_path = '/opt/.ssh/id_rsa'
#     # os.environ['GIT_SSH_COMMAND'] = f'ssh -i {ssh_key_path}'

#     # print('LAYER /opt FOLDER >>> ', os.listdir('/opt'))
#     # print('LAYER /opt/bin FOLDER >>> ', os.listdir('/opt/bin'))
#     # print('LAYER /opt/.ssh FOLDER >>> ', os.listdir('/opt/.ssh'))
#     # tf_bin = '/opt/bin/terraform' # Layer
#     # print('OLD TF BIN >>> ', os.listdir(tf_bin))

#     # for tf_file in os.listdir('/opt/bin'):
#     #     print('files will be sent to /tmp >> ', tf_file)
#     #     shutil.copy(os.path.join('/opt/bin', tf_file), '/tmp')

#     # print('PWD before change dir to /tmp: ', os.getcwd())
#     # print('--- GET FILES before change or PWD >>> ', os.listdir(os.getcwd()))
#     # # Change working directory to /tmp
#     # os.chdir('/tmp')
#     # print('PWD after change dir to /tmp: ', os.getcwd())
#     # print('--- GET FILES after change or PWD >>> ', os.listdir(os.getcwd()))
#     # # tf_bin = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'terraform')
#     # # tf_bin = '/tmp/terraform'
#     # # print('GET FILES /tmp >>> ', os.listdir('/tmp'))
#     # os.chmod('/tmp/terraform', 0o755)
#     # tf_bin = '/tmp/terraform'

#     # terraform_cmds = [
#     #     [tf_bin, 'init', '-reconfigure'],
#     #     # [tf_bin, 'fmt'],
#     #     [tf_bin, 'validate'],
#     #     [tf_bin, 'plan'],
#     #     [tf_bin, 'apply', '-auto-approve'],
#     #     [tf_bin, 'destroy', '-auto-approve']]

#     # for cmd in terraform_cmds:
#     #     run_terraform_command(cmd)

# # def run_terraform_command(cmd):
# #     try:
# #         result = subprocess.run(cmd, capture_output=True, text=True, check=True)
# #         print(f"Terraform command '{' '.join(cmd)}' executed successfully.")
# #         print("STDOUT:\n", result.stdout)
# #         print("STDERR:\n", result.stderr)
# #     except subprocess.CalledProcessError as e:
# #         print(f"Error executing Terraform command '{' '.join(cmd)}':", e)
# #         print("Except STDOUT:\n", e.stdout)
# #         print("Except STDERR:\n", e.stderr)
# #         return {
# #             'statusCode': 500,
# #             'body': json.dumps(f"Error: {str(e)}")
# #         }
# #     else:
# #         return {
# #             'statusCode': 200,
# #             'body': json.dumps('Event processed successfully')
# #         }

# def lambda_handler(event, context):
#     global github_event
#     global repo
#     global name
#     # global email

#     if event['isBase64Encoded']:
#         body = json.loads(base64.b64decode(event['body']).decode('utf-8'))
#     else:
#         body = json.loads(event['body'])
    
#     github_event = event['headers'].get('x-github-event')
#     repo = body['repository']['full_name'].split('/')[1]

#     print('Github Event: ', github_event)
#     print('Repository: ', repo)

#     # if github_event == 'push':
#     #     name = body['commits'][0]['author']['name']
#     #     email = body['commits'][0]['author']['email']
    
#     if github_event == 'pull_request' and repo == 'customer-onboarding-terraform':
#         name = body['pull_request']['user']['login']
#         print('Name: ', name)
#         # aws_check()
#         provision_runners()
#         # return {
#         #     'statusCode': 200,
#         #     'body': json.dumps('Event processed successfully')
#         # }
        


def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda using an ECR container image!'
    }