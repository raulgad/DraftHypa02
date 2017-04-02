# DraftHypa02
Игра-тренажер для счёта (+, -, x, ÷) c настройкой длительности и сложности заданий. Swipe вправо по правильному ответу увеличивает счет.

<img src="Screenshots/right_answer+end_screen.gif" width="320" />

Swipe влево позволяет пропустить ход. После n-го количества пропусков предлагается добавить их еще.

<img src="Screenshots/pass+add_passes.gif" width="320" />

При касании на вопрос можно поменять тип арифметической операции.

<img src="Screenshots/change_operation.gif" width="320" />

## About implementation

Сторонние библиотеки не используются.

CardsViewController – root view controller.
View главного экрана задаётся программно в классе Cards, все остальные экраны задаются в Interface Builder.

Арифметические задания создаются в классе Task. За сложность задания (capacity) отвечает переменная rangeOfSummands, содержащая диапазон чисел, из которых создаются слагаемые выражения. Сложность задания меняется через каждые 5 шагов и задаётся в переменной numberOfStepsToChangeRange.

Классы Score, Passes, Time – синглтоны, отвечающие в игре за счет, пропуски ходов и время соответственно.
