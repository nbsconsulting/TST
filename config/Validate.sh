clear

until read -r -p "Your Commit SHA: " commitSHA && test "$commitSHA" != ""; do
  continue
done

until read -r -p "Your Destination Org : " destOrg && test "$destOrg" != ""; do
  continue
done


echo "Deploy commit $commitSHA."
echo "Modified Files to deploy to $destOrg : "
git diff-tree --no-commit-id --name-only -r "$commitSHA"
echo "+++++++++++++"

files=$(git diff-tree --no-commit-id --name-only --diff-filter=AM -r $commitSHA | tr '\n' ',' | sed 's/,$//')

echo "$files"

sf force source deploy -p "$files" -u "$destOrg" --checkonly
