CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

rm -rf student-submission
rm -rf grading-area

mkdir grading-area

git clone $1 student-submission
echo 'Finished cloning'


# Draw a picture/take notes on the directory structure that's set up after
# getting to this point

# Then, add here code to compile and run, and do any post-processing of the
# tests

# check if the correct file exists
files=`find student-submission`
found=false

for file in $files
do
	if [[ -f $file ]] && [[ $file == *ListExamples* ]]
	then
		echo 'Found ' $file
		found=true
	fi
done

# stop the script if the expected file isn't found
if [ "$found" = false ]
then
	echo 'ListExamples.java not found; exiting script'
	exit 1
fi

# java file is found; move appropriate files into grading-area folder
cp ./*.java student-submission/ListExamples.java ./grading-area
cp -r lib ./grading-area

# switch to grading-area dir
cd ./grading-area

# compile the tests and check the error code
javac -cp .:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar *.java
java -cp .:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar org.junit.runner.JUnitCore TestListExamples > ./output.txt

printf "\n"

# check error of compilation
if [ $? -ne 0 ] 
then
	echo 'Error compiling tests.'
	echo 'Here are the unit test failures: '
	cat output.txt  
	exit 1
else
	echo 'No errors compiling the tests.'
	
fi

# check grade of tests, from output.txt
# check if tests all passed
#result=`grep -h "OK" output.txt`
if grep -qh "OK" output.txt
then
	result=$(grep -wh "OK" output.txt)
	numTests="${result:4:1}"
	passed=$numTests
else
	res=`grep "Tests run: " output.txt`
	sub="Failures"
	rest=${res#*$sub}
	index=$(( ${#res} - ${#rest} - ${#sub} ))
	numTests="${res:11:($index-14)}"
	failed="${res:25}"
	passed=$(expr $numTests - $failed)
fi

printf "\n"

# output tests passed and failed
echo "Tests passed: $passed / $numTests"
grade=$(echo "scale=2; ($passed + $numTests - 1) * 100 / $numTests" | bc)
echo "Grade: $grade%"

exit 0

