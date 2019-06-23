head
====

Output the first lines of a text file.

TODO:
-----
  * Implement `--help` parameter.
  * Implement `--version` parameter.
  * Implement support for files containing parentheses.

Project layout
--------------
  * `src`: Here it is where source code is.
    * `main`: Here it is where source code meant to be part of the application
              lives.
    * `test`: Here it is where the test scripts and other test related files 
              live (so they are not copied when it is installed).

Automatic testing
-----------------
Adding automatic tests to head is quite simple. Simply add a directory 
to src\main\test. Within that directory, add a file named `test-file.txt` 
containing whatever you want to test `head` against. Add a second file 
`prepare-test.bat` with a single command: `SET numberOfLines=` and then the 
number of lines you want to "behead" from `test-file.txt`. Finally, add a third
file `expected-output.txt`, containing what you would expect to see on screen 
after running `head`. And that's it. Run the `test.bat` script at the root 
directory to run it. The directory name will be used as identifier of the test.

---
Below, a markdown cheatsheet.

Heading
=======
Sub-heading
-----------
### Another deeper heading

---

Paragraphs are separated
by a blank line.

Two spaces at the end of a line leave a  
line break.

Text attributes _italic_, *italic*, __bold__, **bold**, `monospace`.

Bullet list:

  * apples
  * oranges
  * pears

Numbered list:

  1. apples
  2. oranges
  3. pears

A [link](http://example.com).

```javascript
function {
  //Javascript highlighted code block.
}
```

    {
    Code block without highlighting.
    }
