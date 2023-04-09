#!/bin/zsh

FILENAME="testing.md"

echo "Cleaning up prior to test execution..."

echo "### NAME FROM README" &>> "$FILENAME"
name=$(grep "^Author:" README.md | awk '{$1=""; print $0}')
reversed=$(echo "$name" | perl -lpe '$_ = join ".", reverse split / /;')
reversed=${reversed//\`/}
echo "$name" &>> "$FILENAME"

echo "" &>> "$FILENAME"
echo "### DIRECTORY NAME" &>> "$FILENAME"
pwd &>> "$FILENAME"

echo "" &>> "$FILENAME"
echo "### GIT COMMITS (2 means no commits from student)" &>> "$FILENAME"
git rev-list --count HEAD &>> "$FILENAME"
echo "" &>> "$FILENAME"

echo "#### CHANGE SUMMARY (Short)" &>> "$FILENAME"
initialCommit=$(git log --format=%H|tail -n 2|head -n 1)
echo "" &>> "$FILENAME"
echo "\`\`\`" &>> "$FILENAME"
echo "" &>> "$FILENAME"
echo `git diff -w --shortstat $initialCommit` &>> "$FILENAME"
echo "\`\`\`" &>> "$FILENAME"
echo "" &>> "$FILENAME"

echo "#### CHANGE SUMMARY (Long)" &>> "$FILENAME"
echo "" &>> "$FILENAME"
echo "\`\`\`" &>> "$FILENAME"
echo "" &>> "$FILENAME"
echo `git diff -w --stat $initialCommit` &>> "$FILENAME"
echo "\`\`\`" &>> "$FILENAME"
echo "" &>> "$FILENAME"

echo "### LAST COMMIT (DueTBD at midnight)" &>> "$FILENAME"
git log -1 --format=%cd --date=local &>> "$FILENAME"

echo "" &>> "$FILENAME"
echo "### README.MD" &>> "$FILENAME"
echo "" &>> "$FILENAME"
cat README.md &>> "$FILENAME"

echo "" &>> "$FILENAME"
echo "" &>> "$FILENAME"

echo "### TEST RESULTS" &>> "$FILENAME"
echo "" &>> "$FILENAME"
mkdir target

echo "#### COMPILING (should be empty)" &>> "$FILENAME"
echo "\`\`\`" &>> "$FILENAME"
find . -name "*.java" > sources.txt
javac -d target -cp target:lib/junit-platform-console-standalone-1.9.0.jar:. @sources.txt &>> "$FILENAME"

if ([ $? -eq 1 ])
then
  echo "\`\`\`" &>> "$FILENAME"
  echo "" &>> "$FILENAME"
  echo "**Failed to compile; unable to run tests**" &>> "$FILENAME"
  echo "" &>> "$FILENAME"
else
  echo "" &>> "$FILENAME"
  echo "\`\`\`" &>> "$FILENAME"
  echo "" &>> "$FILENAME"

  echo "#### OperatorsTest (7 tests)" &>> "$FILENAME"
  echo "\`\`\`" &>> "$FILENAME"
  java -jar ./lib/junit-platform-console-standalone-1.9.0.jar -cp target --select-class=tests.requirements.OperatorsTest --disable-banner | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' &>> "$FILENAME"
  echo "" &>> "$FILENAME"
  echo "\`\`\`" &>> "$FILENAME"
  echo "" &>> "$FILENAME"

  echo "#### TypeTests (4 tests)" &>> "$FILENAME"
  echo "\`\`\`" &>> "$FILENAME"
  java -jar ./lib/junit-platform-console-standalone-1.9.0.jar -cp target --select-class=tests.requirements.TypeTests --disable-banner | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' &>> "$FILENAME"
  echo "" &>> "$FILENAME"
  echo "\`\`\`" &>> "$FILENAME"
  echo "" &>> "$FILENAME"

  echo "#### IfStatementTests (2 tests)" &>> "$FILENAME"
  echo "" &>> "$FILENAME"

  echo "\`\`\`" &>> "$FILENAME"
  java -jar ./lib/junit-platform-console-standalone-1.9.0.jar -cp target --select-class=tests.requirements.IfStatementTests --disable-banner | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' &>> "$FILENAME"
  echo "" &>> "$FILENAME"
  echo "\`\`\`" &>> "$FILENAME"
  echo "" &>> "$FILENAME"

  echo "#### UnlessStatementTest (1 test)" &>> "$FILENAME"
  echo "" &>> "$FILENAME"

  echo "\`\`\`" &>> "$FILENAME"
  java -jar ./lib/junit-platform-console-standalone-1.9.0.jar -cp target --select-class=tests.requirements.UnlessStatementTest --disable-banner | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' &>> "$FILENAME"
  echo "" &>> "$FILENAME"
  echo "\`\`\`" &>> "$FILENAME"
  echo "" &>> "$FILENAME"

  echo "#### SelectStatementTest (3 tests)" &>> "$FILENAME"
  echo "" &>> "$FILENAME"

  echo "\`\`\`" &>> "$FILENAME"
  java -jar ./lib/junit-platform-console-standalone-1.9.0.jar -cp target --select-class=tests.requirements.SelectStatementTest --disable-banner | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' &>> "$FILENAME"
  echo "" &>> "$FILENAME"
  echo "\`\`\`" &>> "$FILENAME"
  echo "" &>> "$FILENAME"

  echo "#### OutputTest (1 test)" &>> "$FILENAME"
  echo "" &>> "$FILENAME"

  echo "\`\`\`" &>> "$FILENAME"
  java -jar ./lib/junit-platform-console-standalone-1.9.0.jar -cp target --select-class=tests.requirements.OutputTest --disable-banner | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' &>> "$FILENAME"
  echo "" &>> "$FILENAME"
  echo "\`\`\`" &>> "$FILENAME"
  echo "" &>> "$FILENAME"
fi

echo "#### New ASTs added" &>> "$FILENAME"
echo "" &>> "$FILENAME"

for astname in HexTree HexTypeTree StringTree StringTypeTree SelectBlockTree SelectorTree SelectTree UnlessTree
do
  if [ -f "./ast/$astname.java" ]
  then
    echo "* $astname ✔" &>> "$FILENAME"
  else
    echo "* $astname X" &>> "$FILENAME"
  fi
  echo "" &>> "$FILENAME"
done

echo "#### Visitor updated" &>> "$FILENAME"
echo "" &>> "$FILENAME"

for methodname in visitStringTypeTree visitHexTypeTree visitStringTree visitHexTree visitUnlessTree visitSelectTree visitSelectBlockTree visitSelectorTree
do
  if ( grep -q $methodname ./visitor/ASTVisitor.java; [ $? -eq 0 ] )
  then
    echo "* $methodname ✔" &>> "$FILENAME"
  else
    echo "* $methodname X" &>> "$FILENAME"
  fi
  echo "" &>> "$FILENAME"
done

echo "#### Visitor classes created" &>> "$FILENAME"

for filename in OffsetVisitor DrawOffsetVisitor
do
  if [[ -f "./visitor/$filename.java" ]]; then
    echo "* $filename ✔" &>> "$FILENAME"

      echo "" &>> "$FILENAME"
      echo "\`\`\`java" &>> "$FILENAME"
      cat "./visitor/$filename.java" &>> "$FILENAME"
      echo "" &>> "$FILENAME"
      echo "\`\`\`" &>> "$FILENAME"
      echo "" &>> "$FILENAME"
  else
    echo "* $filename X" &>> "$FILENAME"
  fi
done

echo "" &>> "$FILENAME"

echo "#### Executing with basic.x" &>> "$FILENAME"
rm -rf target
echo "" &>> "$FILENAME"
echo "\`\`\`" &>> "$FILENAME"
echo "" &>> "$FILENAME"
javac -d target -cp compiler/*.java &>> "$FILENAME"

if ([ $? -eq 1 ])
then
  echo "\`\`\`" &>> "$FILENAME"
  echo "" &>> "$FILENAME"
  echo "**Failed to compile; unable to run compiler**" &>> "$FILENAME"
  echo "" &>> "$FILENAME"
else
  java -cp target compiler.Compiler ./sample_files/basic.x -image &>> "$FILENAME" 2>&1
  echo "" &>> "$FILENAME"
  echo "\`\`\`" &>> "$FILENAME"
  echo "" &>> "$FILENAME"
  if [ -f ./sample_files/basic.x.png ]
  then
    convert ./sample_files/basic.x.png -resize 600x600^ ./sample_files/basic.png
    echo "![basic.x AST](./sample_files/basic.png)" &>> "$FILENAME"
    echo "" >> "$FILENAME"
  else
    echo "**Could not find image ./sample_files/basic.x.png**" &>> "$FILENAME"
    echo "" >> "$FILENAME"
  fi

    echo "#### Executing with valid_new_statements.x" &>> "$FILENAME"
    echo "\`\`\`" &>> "$FILENAME"
    java -cp target compiler.Compiler ./sample_files/valid_new_statements.x -image &>> "$FILENAME" 2>&1
    echo "" &>> "$FILENAME"
    echo "\`\`\`" &>> "$FILENAME"
    echo "" &>> "$FILENAME"
    if [ -f ./sample_files/valid_new_statements.x.png ]
    then
      convert ./sample_files/valid_new_statements.x.png -resize 600x600^ ./sample_files/valid_new_statements.png
      echo "![valid_new_statements.x AST](./sample_files/valid_new_statements.png)" &>> "$FILENAME"
      echo "" >> "$FILENAME"
    else
      echo "**Could not find image ./sample_files/valid_new_statements.x.png**" &>> "$FILENAME"
      echo "" >> "$FILENAME"
    fi
  fi

  echo "" &>> "$FILENAME"
  echo "### CODE QUALITY SAMPLE - Parser.java" &>> "$FILENAME"
  echo "Checking for code quality and appropriate factoring of new methods." &>> "$FILENAME"
  echo "" &>> "$FILENAME"
  echo "\`\`\`java" &>> "$FILENAME"
  cat parser/Parser.java &>> "$FILENAME"
  echo "" &>> "$FILENAME"
  echo "\`\`\`" &>> "$FILENAME"
  echo "" &>> "$FILENAME"

  # dir=${PWD##*/}
  # mv $FILENAME "${reversed}-$dir.md"
  # branch=grading-${date +%s%3N}

  # git checkout -b $branch
  # mv $FILENAME README.md
  # git add README.md
  # git push -u origin $branch

done