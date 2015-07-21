
defmodule Mix.Tasks.Install do

    def run(_) do
        Amnesia.Schema.create
     
        Amnesia.start
     
        Database.create(disk: [node])
     
        # This waits for the database to be fully created.
        Database.wait
     
        # Stop mnesia so it can flush everything and keep the data sane.
        Amnesia.stop
    end

end


defmodule Mix.Tasks.UnInstall do
    use Mix.Task
    use Database

    def run(_) do
        # Start mnesia, or we can't do much.
        Amnesia.start
     
        # Destroy the database.
        Database.destroy
     
        # Stop mnesia, so it flushes everything.
        Amnesia.stop
     
        # Destroy the schema for the node.
        Amnesia.Schema.destroy
    end

end

