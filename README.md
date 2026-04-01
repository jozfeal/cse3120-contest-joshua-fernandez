# CSE3120 Computer Architecture and Assembly Programming Spring 2026 - Contest 1
## Joshua Fernandez-Alvarado (904036400)

## How to Play
**Controls**
- When prompted with a text field, type a response and press Enter to confirm.
- When prompted with a menu selection, press the Up and Down Arrow Keys to move your selection.
- Press Z to confirm your selected choice.
- At any point except during text prompts, you may press Esc to immediately quit the game.

**Gameplay**
- The game consists of a simple 3v3 turn based battle, the you vs the computer.
- When the game begins, you may configure your party. For each of your units type a name and select a role.
- Roles:
  - Warrior: Balanced in all stats.
  - Archer: High attack damage but frail.
  - Knight: High defenses but low attack damage.
- Once the battle begins, choose each unit will get a turn one after the other until either team is defeated completely.
- Options:
  - Attack: Performs an attack to reduce enemy health, you will be prompted with a choice of which enemy to attack.
  - Defend: Does nothing as of this version of the game, simply skips your turn.
  - Spell: Does nothing as of this version of the game, simply skips your turn.

## How to Compile and Run
- This project compiles using Visual Studio 15, all you must do is open the AssemblyContest.sln file, where you can build and run it from.
- If you wish to compile and run in the command line, open the provided compile.bat file and modify the paths. The current paths work for my computer but may not for yours.
- If you do not know how to find the correct paths for you, refer to the assingment at the start of the semester: "Lab Start - Configuring Windows Command-Line Compilers".
- Copy and paste your paths section over mine.
- Once the paths have been edit, you need only go to the repository folder and run the following command to compile:
`compile.bat`
- After compilation, run the following command to begin the game:
`main`
- **Important Note**: if you return to a previous commit in which compile.bat does not exist, make sure to edit the .asm and .obj options for the ml and link commands to not include files that may not have existed in the repository up to that point.
