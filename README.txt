Ruby Derailed: Tricks, Idioms, and Experiments in Application Development

This is strictly non-Rails content (although there will a Sinatra component
for those addicted to web development).

The session will consist of introductory material followed by live coding
and discussion. The coding will be on a small application called Socrates
(at present fewer than 20 classes and fewer than 1,000 lines of code).
See individual sections below for more information.

github repo: Coming soon
Online slides: Coming soon

Software prerequisites: 

  For everyone:
    Linux, OS/X or equivalent
    git
    Ruby 1.9.2
    SQLite
    Gems: Bundler, minitest, sqlite3
    rvm or rbenv
  For those wanting to work on Swing interface:
    JVM
    JRuby 1.6.7 
  For those wanting to code a web interface:
    Sinatra 

Schedule (breaks are assumed):

  Hour 1: 
    - Tips, tricks, edge cases, and advanced techniques
    - People start cloning repo (allow for wifi trouble)
    - Refresher: Best practices, tools, app structure
    - Overview of Socrates
       * Question types and terminology
       * Classes and code structure
       * The text UI
       * "to do today" (and someday)
  Hour 2:
    - Basics of Sequel
    - Basics of Sinatra
    - Basics of Swing
    - Basics of minitest
    - First dev cycle (short)
  Hours 3-6:
    - Four dev cycles
    - Final cycle may be shortened for summary/discussion

Socrates is: 

    A tool for quizzing on various topics, designed to be effective, flexible, and
    extensible. It is intended to support multiple users, hierarchies of topics, and 
    multiple question types.  Ultimately, a sophisticated algorithm will maximize 
    memory and learning efficiency. Part of its purpose is an experiment in attaching
    multiple user interfaces to an "engine" or model.

Coding guidelines:

  - Maintain separation of concerns and modularity
  - Keep model or engine decoupled from interface
  - Test as much as possible (TDD not required)
  - Seek a high abstraction of data access
  - Keep the data store "agnostic" of DB and ORM
  - Maintain code style and readability
  
Coding tasks:

  - Implement the "complex multiple choice" question type
  - Add tests as needed (new or existing code)
  - Implement a partial web interface via Sinatra
  - Implement a partial desktop interface via JRuby/Swing
  - Implement a simple "question editor"
  - Implement a mini-DSL for adding questions
  - Other as time and interest permit

"Rules of engagement":

  - Work alone or pair-program
  - "Test often, commit often"
  - Follow rational versioning
  - We'll mediate patch numbers "ad hoc"
  - Minimal coding standard (see below)
  - At least four (4) dev cycles after intro
  - Part of each dev cycle is class-wide code review
  - Coding ceases during code review
  - Update gemspec, release notes as needed
  - After review, code is merged and tested
  - Record any comments/observations (including "meta")
  - Ideally, each person/team runs all tests
  - Then coding may resume

Coding standard:

  - Two-space indentation (hard spaces, no tabs)
  - No Windows-style newlines
  - No lines over 80 characters
  - Essentially "one statement per line"
  - Keep statement continuation to a minimum
  - Avoid multi-statement lines
  - But multiple assignment is OK
  - No methods over 20 lines
  - CamelCaseForConstants and snake_case_elsewhere
  - Parentheses on method definitions, please
  - Parentheses on method calls at your taste/discretion
  - Single-line blocks use {}
  - Multi-line blocks use do/end
  - Align righthand comments as needed
  - In general, avoid hashes faking named parameters
  
