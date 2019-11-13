require "spec_helper"

describe Doodlesack do
  describe "self#run(command_line_arguments)" do
    context "command_line_arguments is an empty array" do
      it "prints a usage description" do
        expect do
          Doodlesack.run([])
        end.to(
          output("USAGE: doodlesack [setup|deploy]\n").to_stdout
        )
      end
    end

    context "the command is not a doodlesack command" do
      it "prints a usage description" do
        expect do
          Doodlesack.run(["not_a_doodlesack_command"])
        end.to(
          output("USAGE: doodlesack [setup|deploy]\n").to_stdout
        )
      end
    end

    context "the command is not called from within an Expo project directory" do
      it "instructs the user to run the command in an Expo project directory" do
        allow(Doodlesack::Deploy).to receive(:run)
        allow(File).to receive(:file?).with("app.json").and_return(false)
        allow_any_instance_of(Doodlesack).to receive(:`)
          .with("git status")
          .and_return("nothing to commit, working tree clean")

        expect do
          Doodlesack.run(["deploy"])
        end.to(
          output("No app.json file present. Are you in an Expo project directory?\n").to_stdout
        )
        expect(Doodlesack::Deploy).not_to have_received(:run)
      end
    end

    context "command_line_arguments is ['setup']" do
      it "calls Doodlesack::Setup.run" do
        allow(File).to receive(:file?).with("app.json").and_return(true)
        allow(Doodlesack::Setup).to receive(:run)

        Doodlesack.run(["setup"])

        expect(Doodlesack::Setup).to have_received(:run)
      end

      it "does not call Doodlesack::Deploy.run" do
        allow(File).to receive(:file?).with("app.json").and_return(true)
        allow_any_instance_of(Doodlesack).to receive(:`)
          .with("git status")
          .and_return("nothing to commit, working tree clean")
        allow(Doodlesack::Deploy).to receive(:run)

        Doodlesack.run(["setup"])

        expect(Doodlesack::Deploy).not_to have_received(:run)
      end
    end

    context "command_line_arguments is ['deploy']" do
      it "calls Doodlesack::Deploy.run" do
        allow(Doodlesack::Deploy).to receive(:run)
        allow(File).to receive(:file?).with("app.json").and_return(true)
        allow_any_instance_of(Doodlesack).to receive(:`)
          .with("git status")
          .and_return("nothing to commit, working tree clean")

        Doodlesack.run(["deploy"])

        expect(Doodlesack::Deploy).to have_received(:run)
      end

      it "does not call Doodlesack::Setup.run" do
        allow(Doodlesack::Setup).to receive(:run)
        allow(Doodlesack::Deploy).to receive(:run)
        allow(File).to receive(:file?).with("app.json").and_return(true)
        allow_any_instance_of(Doodlesack).to receive(:`)
          .with("git status")
          .and_return("nothing to commit, working tree clean")

        Doodlesack.run(["deploy"])

        expect(Doodlesack::Setup).not_to have_received(:run)
      end

      context "the git status is not clean when the command is run" do
        it "instructs the user to commit their changes before deploying" do
          allow(Doodlesack::Deploy).to receive(:run)
          allow(File).to receive(:file?).with("app.json").and_return(true)
          allow_any_instance_of(Doodlesack).to receive(:`)
            .with("git status")
            .and_return("changes present")

          expect do
            Doodlesack.run(["deploy"])
          end.to(
            output("Nothing was deployed because you need to commit your changes to git first.\n").to_stdout
          )
          expect(Doodlesack::Deploy).not_to have_received(:run)
        end
      end
    end
  end
end
