# todo: accept file pattern and replace pattern as arguments
for f in *.json
do
  mv $f $(echo $f|sed 's/tobacco_milestone_/tobacco_milestone/g')
done
