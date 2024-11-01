require_relative '../megaverseentity'
require 'json'

RSpec.describe MegaverseEntity do
  let (:test_row) { 1 }
  let (:test_column) { 2 }

  describe '.create' do
    it 'raises argument error on negative row' do
      expect { MegaverseEntity.create(-1, test_column) }.to raise_error(ArgumentError)
    end

    it 'raises argument error on negative column' do
      expect { MegaverseEntity.create(test_row, -1) }.to raise_error(ArgumentError)
    end

    it 'propagates exceptions raised by Requester.postPayload' do
      allow(Requester).to receive(:postPayload).and_raise(Requester::RequesterError.new("Mocked error"))

      expect { MegaverseEntity.create(test_row, test_column) }.to raise_error(MegaverseEntity::MegaverseEntityError)
    end

    context 'without extra arguments' do
      it 'creates json payload' do
        expect(Requester).to receive(:postPayload)

        json_output = MegaverseEntity.create(test_row, test_column)

        # Check if the output is a valid JSON string
        expect { JSON.parse(json_output) }.not_to raise_error

        # Check the parsed structure
        parsed_data = JSON.parse(json_output)
        expect(parsed_data).to be_a(Hash)
        expect(parsed_data['row']).to eq(test_row)
        expect(parsed_data['column']).to eq(test_column)
        expect(parsed_data.keys.sort).to eq(['row', 'column', 'candidateId'].sort)
      end
    end

    context 'with extra arguments' do
      it 'raises argument error non hash extra' do
        expect { MegaverseEntity.create(test_row, test_column, '1') }.to raise_error(ArgumentError)
        expect { MegaverseEntity.create(test_row, test_column, 1) }.to raise_error(ArgumentError)
        expect { MegaverseEntity.create(test_row, test_column, 1.0) }.to raise_error(ArgumentError)
      end

      it 'creates json payload with description' do
        description = 'this is an example'

        expect(Requester).to receive(:postPayload)

        json_output = MegaverseEntity.create(test_row, test_column, description: description )

        # Check if the output is a valid JSON string
        expect { JSON.parse(json_output) }.not_to raise_error

        # Check the parsed structure
        parsed_data = JSON.parse(json_output)
        expect(parsed_data).to be_a(Hash)
        expect(parsed_data['row']).to eq(test_row)
        expect(parsed_data['column']).to eq(test_column)
        expect(parsed_data['description']).to eq(description)
      end
    end
  end
end
