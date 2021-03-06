% Board is a one dimensional array of the following values:
%   x - The symobol for player X
%   o - The symbol for player O
%   0 - 0 If the spot is empty
% An example of a valid 2x2 board:
%   [x, 0, 0, o]
%
% Notes:
%   - All over the documentation, "+" is an input variable and "-" an output
%


% miniMax(+Depth +Player, +Board, -BestMove)
% Find the best move Player can make on Board.
% :param Depth: The depth of the alpha-beta pruhning, a number
% :param Player: The symbol the computer needs to play, x or o
% :param Board: Representation of the board (see top comment)
% :return BestMove: The new board with the best possible move chosen.
%   Returns the same board if there's a win / draw on given board.
miniMax(_, Player, Board, Board) :-
    isWinning(Player, Board);
    otherPlayer(Player, OtherPlayer),
    isWinning(OtherPlayer, Board);
    isDraw(Board).

miniMax(Depth, Player, Board, BestMove) :-
    \+ validateInput(Depth, Player, Board),
    miniMaxStep(Depth, Player, Player, max, Board, BestMove, _).



% validateInput(+Depth, +Player, +Board)
% Validates all miniMax input parameters,
% Throws exception if something is invalid.
validateInput(Depth, Player, Board) :-
    \+ isBoardValid(Board),
    throw("Board contains invalid signs!");

    \+ isProperSize(Board),
    throw("Board is inpropely sized!");

    \+ otherPlayer(Player, _),
    throw("Invalid input Player!");

    Depth < 1,
    throw("Invalid input Depth!").



% miniMaxStep(+Depth, +OriginalPlayer, +Player, +MinMax, +Board, -BestMove, -BestScore)
% Finds the best move Player can make on Board (by trying to maximize BestScore).
% :param OriginalPlayer: Keep track of the original player - needed for scoring.
%   This is needed for supporting computer being both X and O
miniMaxStep(Depth, OriginalPlayer, Player, MinMax, Board, BestMove, BestScore) :-
    Depth > 0,
    NewDepth is Depth - 1,
    allMoves(Player, Board, AllMoves),
    bestMove(NewDepth, OriginalPlayer, Player, MinMax, AllMoves, BestMove, BestScore).

miniMaxStep(_, OriginalPlayer, _, _, Board, _, Score) :-
    scoreBoard(0, OriginalPlayer, Board, Score).


% bestMove(+Depth, +OriginalPlayer, +Player, +MinMax, +AllMoves, -BestMove, -BestScore)
% Choose the next move.

% Pick best scoring move out of moves
bestMove(Depth, OriginalPlayer, Player, MinMax, [Move | OtherMoves], BestMove, BestScore) :-
    scoreBoard(Depth, OriginalPlayer, Move, Score),
    bestMove(Depth, OriginalPlayer, Player, MinMax, OtherMoves, CurrentBestMove, CurrentBestScore),
    compareMoves(MinMax, Move, Score, CurrentBestMove, CurrentBestScore, BestMove, BestScore).

bestMove(Depth, OriginalPlayer, Player, MinMax, [Move | OtherMoves], BestMove, BestScore) :-
    bestMove(Depth, OriginalPlayer, Player, MinMax, OtherMoves, CurrentBestMove, CurrentBestScore),
    otherPlayer(Player, OtherPlayer),
    switchMinMax(MinMax, OtherMinMax),
    miniMaxStep(Depth, OriginalPlayer, OtherPlayer, OtherMinMax, Move, _, LeafBestScore),
    compareMoves(MinMax, Move, LeafBestScore, CurrentBestMove, CurrentBestScore, BestMove, BestScore).

% If no boards left and MinMax is max.
bestMove(_, _, _, max, [], [], -2).

% If no boards left and MinMax is min.
bestMove(_, _, _, min, [], [], 2).



% compareMoves(+MinMax, +MoveA, +ScoreA, +MoveB, +ScoreB, -BetterMove, -BetterScore)
% Compare MoveA and MoveB (with respective scores) and pick the better one.
% Also takes current MinMax value into fact.
% If MinMax is max

compareMoves(max, MoveA, ScoreA, _, ScoreB, MoveA, ScoreA) :-
    ScoreA >= ScoreB, !.

compareMoves(max, _, ScoreA, MoveB, ScoreB, MoveB, ScoreB) :-
    ScoreA < ScoreB, !.

% If MinMax is min
compareMoves(min, MoveA, ScoreA, _, ScoreB, MoveA, ScoreA) :-
    ScoreA =< ScoreB, !.

compareMoves(min, _, ScoreA, MoveB, ScoreB, MoveB, ScoreB) :-
    ScoreA > ScoreB, !.



% scoreBoard(+Depth, +Player, +Board, -Score)
% Give score to board based on Player symbol and given board.
% Given +1 for win, -1 for loose, 0 for tie.
% :param Player: The symbol of the player we want to check
% :param Board: The baord we want to check
% :return Score: The score for the board (1, -1, 0).

% If empty board
scoreBoard(_, _, [], Score) :-
    Score is 0.

% If depth is zero
scoreBoard(0, _, _, Score) :-
    Score is 0.

% If Player is winning +1
scoreBoard(_, P, Board, Score) :-
    isWinning(P, Board),
    Score is 1, !.

% If other player is winning -1
scoreBoard(_, P, Board, Score) :-
    otherPlayer(P, P2),
    isWinning(P2, Board),
    Score is -1, !.

% If draw 0
scoreBoard(_, _, Board, Score) :-
    isDraw(Board),
    Score is 0, !.



% allMoves(+Player, +Board, -AllMoves)
% Generate all possible moves for player
% :return AllMoves: All possible boards for legal move.
allMoves(P, Board, AllMoves) :-
    findall(NextBoard, makeMove(P, Board, NextBoard), AllMoves).



% makeMove(+Player, +Board, -NextBoard)
% True if Next board is Board with an empty cell replaced with
%   Player symbol.
% :return NextBoard: The board with move made.
makeMove(P, [B|Bs], [B|B2s]) :-
    makeMove(P, Bs, B2s).

% Place P if empty spot found
makeMove(P, [0|Bs], [P|Bs]).



% otherPlayer(+Player, -OtherPlayer)
% Return the alternate player of given player Player
otherPlayer(x, o).
otherPlayer(o, x).


% switchMinMax(+MinMax, -TheOther)
% Returns the alternate of min/max
switchMinMax(min, max).
switchMinMax(max, min).


% isProperSymbol(+Symbol)
% Returns true if Symbol is a valid symbol for the board (x, o, 0)
isProperSymbol(x).
isProperSymbol(o).
isProperSymbol(0).


% isDraw(+Board)
% Returns True if all spots on board are taken (!= 0)
isDraw(Board) :-
    \+ member(0, Board).


% isBoardValid(+Board)
% Return true if board contains only proper symbols.
isBoardValid([CurrentSymbol|OtherSymbols]) :-
    isProperSymbol(CurrentSymbol),
    isBoardValid(OtherSymbols).

% Base case
isBoardValid([]).


% This will be commented out when generating from template
% {#

% isWinning(+Player, +Board)
% Check if player is isWinning in board
% :param Player: The symbol of player we want to check.
% :param Board: The board we want to check.
isWinning(P, [X1, X2, X3, X4, X5, X6, X7, X8, X9]) :-
    equal(P, X1, X2, X3);
    equal(P, X4, X5, X6);
    equal(P, X7, X8, X9);
    equal(P, X1, X4, X7);
    equal(P, X2, X5, X8);
    equal(P, X3, X6, X9);
    equal(P, X1, X5, X9);
    equal(P, X3, X5, X7).


% equal(+X1, +X2, +X3, +X4)
% Helper method for "isWinning", check if all symbols match.
% True if X1 = X2 = X3 = X4.
equal(X, X, X, X).


% isProperSize(+Board)
% Check that Board is at a correct XO board size.
isProperSize([_, _, _, _, _, _, _, _, _]).


% #}

% --------------------------------------------------------- %
% Code here is Python auto generated code for better        %
% "any size" tic-tac-toe game support.                      %
% This uses Jinja2 templating to insert the additional      %
% isWinning + equal matching the required board size        %
% --------------------------------------------------------- %

% {{ board_statements }}
