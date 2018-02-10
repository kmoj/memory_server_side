defmodule Memory.Game do
  def new do
    %{
      letters: shuffle_letter(),
      lastClicked: nil,
      isDisabled: false,
      isClicked: List.duplicate(false, 16),
      corrects:  List.duplicate(false, 16),
      count: 2,
      scores: 0,
    }
  end

  def shuffle_letter do
    letters = ["A", "B", "C", "D", "E", "F", "G", "H"]
    letters = Enum.concat(letters, letters)
    Enum.shuffle(letters)
  end

  def client_view(game) do
    %{
      letters: game.letters,
      lastClicked: game.lastClicked,
      isDisabled: game.isDisabled,
      isClicked: game.isClicked,
      corrects:  game.corrects,
      count: game.count,
      scores: game.scores,
    }
  end

  def click_tile(game, i) do
    lastClicked = game.lastClicked
    if lastClicked == nil do
      lastClicked = 999
    end
    if Enum.at(game.letters, i) == Enum.at(game.letters, lastClicked)
       && i != game.lastClicked
       && game.count >0 do
      new_corrects = List.replace_at(game.corrects, i, true)
      new_corrects = List.replace_at(new_corrects, lastClicked, true)
      %{
        letters: game.letters,
        lastClicked: i,
        isDisabled: game.isDisabled,
        isClicked: game.isClicked,
        corrects:  new_corrects,
        count: 2,
        scores: game.scores + 10,
      }
    else
      new_count = game.count
      if (new_count > 0) do
        new_count = new_count - 1
        new_clicked = List.replace_at(game.isClicked, i, true)
        new_clicked = List.replace_at(new_clicked, lastClicked, true)
      else
        new_clicked = List.replace_at(game.isClicked, i, true)
        new_count = 1
      end

      %{
        letters: game.letters,
        lastClicked: i,
        isDisabled: true,
        isClicked: new_clicked,
        corrects:  game.corrects,
        count: new_count,
        scores: game.scores - 1,
      }

    end
  end

  def undisable(game, i) do

    new_clicked = List.duplicate(false, 16)
    if game.count > 0 do
      new_clicked  = List.replace_at(new_clicked, i, true)
    end

    %{
      letters: game.letters,
      lastClicked: i,
      isDisabled: false,
      isClicked: new_clicked,
      corrects:  game.corrects,
      count: game.count,
      scores: game.scores,
    }
  end

  def reload(game) do
    %{
      letters: game.letters,
      lastClicked: game.lastClicked,
      isDisabled: false,
      isClicked: game.isClicked,
      corrects:  game.corrects,
      count: game.count,
      scores: game.scores,
    }
  end

end
