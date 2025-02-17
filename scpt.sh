#!/bin/bash

# Configuration
INSTANCE_A_IP="172.31.22.64"  # Private IP of Instance A
INSTANCE_B_IP="172.31.81.168"  # Private IP of Instance B
KEY_PATH="my-key.pem"           # Key file (must be in the current directory)
FILE_TO_TRANSFER="test.txt"    # File to transfer

# Step 1: Ensure key file exists
if [ ! -f "$KEY_PATH" ]; then
  echo "Error: Key file '$KEY_PATH' not found in the current directory."
  exit 1
fi

# Step 2: Set correct permissions for the key
chmod 400 $KEY_PATH

# Step 3: Copy the key to Instance A from local
scp -i $KEY_PATH $KEY_PATH ubuntu@$INSTANCE_A_IP:/home/ubuntu/my-key.pem || {
  echo "Error: SCP to Instance A failed."
  exit 1
}

# Step 4: SCP from Instance A to Instance B
ssh -i $KEY_PATH ubuntu@$INSTANCE_A_IP << 'EOF'
  chmod 400 /home/ubuntu/my-key.pem
  scp -i /home/ubuntu/my-key.pem /home/ubuntu/'$FILE_TO_TRANSFER' ubuntu@'$INSTANCE_B_IP':/home/ubuntu/
EOF

# Step 5: Verify the transfer on Instance B
ssh -i $KEY_PATH ubuntu@$INSTANCE_B_IP "ls /home/ubuntu/ && echo '✅ File Transfer Successful'"

# Step 6: Clean up the key from Instance A
ssh -i $KEY_PATH ubuntu@$INSTANCE_A_IP "rm -f /home/ubuntu/my-key.pem"

echo "SCP Transfer Process Completed."
