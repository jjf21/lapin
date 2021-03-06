describe Creneau, type: :model do
  let!(:motif) { create(:motif, name: "Vaccination", default_duration_in_min: 30, online: online) }
  let(:online) { true }
  let!(:lieu) { create(:lieu) }
  let(:today) { Date.new(2019, 9, 19) }
  let(:six_days_later) { Date.new(2019, 9, 25) }
  let!(:plage_ouverture) { create(:plage_ouverture, motifs: [motif], lieu: lieu, first_day: today, start_time: Tod::TimeOfDay.new(9), end_time: Tod::TimeOfDay.new(11)) }
  let(:agent) { plage_ouverture.agent }
  let(:now) { today.to_time }
  let(:for_agents) { nil }
  let(:agent_ids) { nil }

  before { travel_to(now) }
  after { travel_back }

  describe ".for_motif_and_lieu_from_date_range" do
    let(:motif_name) { motif.name }
    let(:next_7_days_range) { today..six_days_later }

    subject { Creneau.for_motif_and_lieu_from_date_range(motif_name, lieu, next_7_days_range, for_agents, agent_ids) }

    it do
      expect(subject.size).to eq(4)

      expect_creneau_to_eq(subject[0], starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
      expect_creneau_to_eq(subject[1], starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
      expect_creneau_to_eq(subject[2], starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
      expect_creneau_to_eq(subject[3], starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
    end

    describe "with not online motif" do
      let(:online) { false }

      it { expect(subject.size).to eq(0) }

      describe "when the result is for pros" do
        let(:for_agents) { true }

        it do
          expect(subject.size).to eq(4)

          expect_creneau_to_eq(subject[0], starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
          expect_creneau_to_eq(subject[1], starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
          expect_creneau_to_eq(subject[2], starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
          expect_creneau_to_eq(subject[3], starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
        end
      end
    end

    describe "with absence" do
      let!(:absence) { create(:absence, agent: agent, starts_at: Time.zone.local(2019, 9, 19, 9, 45), ends_at: Time.zone.local(2019, 9, 19, 10, 15)) }

      it do
        expect(subject.size).to eq(2)

        expect_creneau_to_eq(subject[0], starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
        expect_creneau_to_eq(subject[1], starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
      end
    end

    describe "with rdv" do
      let!(:rdv) { create(:rdv, starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, agents: [agent]) }

      it do
        expect(subject.size).to eq(3)

        expect_creneau_to_eq(subject[0], starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
        expect_creneau_to_eq(subject[1], starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
        expect_creneau_to_eq(subject[2], starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
      end
    end

    describe "when there is two agent" do
      let(:agent2) { create(:agent) }
      let!(:plage_ouverture2) { create(:plage_ouverture, agent: agent2, motifs: [motif], lieu: lieu, first_day: today, start_time: Tod::TimeOfDay.new(10), end_time: Tod::TimeOfDay.new(12)) }

      it do
        expect(subject.size).to eq(6)

        expect_creneau_to_eq(subject[0], starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
        expect_creneau_to_eq(subject[1], starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
        expect_creneau_to_eq(subject[2], starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
        expect_creneau_to_eq(subject[3], starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
        expect_creneau_to_eq(subject[4], starts_at: Time.zone.local(2019, 9, 19, 11, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
        expect_creneau_to_eq(subject[5], starts_at: Time.zone.local(2019, 9, 19, 11, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
      end

      describe "when the result is for pros" do
        let(:for_agents) { true }

        it do
          expect(subject.size).to eq(8)

          expect_creneau_to_eq(subject[0], starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent.id, agent_name: agent.short_name)
          expect_creneau_to_eq(subject[1], starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent.id, agent_name: agent.short_name)
          expect_creneau_to_eq(subject[2], starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent2.id, agent_name: agent2.short_name)
          expect_creneau_to_eq(subject[3], starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent.id, agent_name: agent.short_name)
          expect_creneau_to_eq(subject[4], starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent2.id, agent_name: agent2.short_name)
          expect_creneau_to_eq(subject[5], starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent.id, agent_name: agent.short_name)
          expect_creneau_to_eq(subject[6], starts_at: Time.zone.local(2019, 9, 19, 11, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent2.id, agent_name: agent2.short_name)
          expect_creneau_to_eq(subject[7], starts_at: Time.zone.local(2019, 9, 19, 11, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent2.id, agent_name: agent2.short_name)
        end

        describe "and filtered for agent2" do
          let(:agent_ids) { [agent2.id] }

          it do
            expect(subject.size).to eq(4)

            expect_creneau_to_eq(subject[0], starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent2.id, agent_name: agent2.short_name)
            expect_creneau_to_eq(subject[1], starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent2.id, agent_name: agent2.short_name)
            expect_creneau_to_eq(subject[2], starts_at: Time.zone.local(2019, 9, 19, 11, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent2.id, agent_name: agent2.short_name)
            expect_creneau_to_eq(subject[3], starts_at: Time.zone.local(2019, 9, 19, 11, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif, agent_id: agent2.id, agent_name: agent2.short_name)
          end
        end
      end
    end

    describe "when motif has min_booking_delay" do
      let!(:motif) { create(:motif, name: "Vaccination", default_duration_in_min: 30, min_booking_delay: 30.minutes, online: true) }
      let(:now) { Time.zone.local(2019, 9, 19, 9, 15) }

      it do
        expect(subject.size).to eq(2)

        expect_creneau_to_eq(subject[0], starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
        expect_creneau_to_eq(subject[1], starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif: motif)
      end
    end

    def expect_creneau_to_eq(creneau, attr = {})
      expect(creneau.starts_at).to eq(attr[:starts_at])
      expect(creneau.duration_in_min).to eq(attr[:duration_in_min])
      expect(creneau.lieu.id).to eq(attr[:lieu_id])
      expect(creneau.motif.id).to eq(attr[:motif].id)
      expect(creneau.agent_id).to eq(attr[:agent_id]) if attr[:agent_id].present?
      expect(creneau.agent_name).to eq(attr[:agent_name]) if attr[:agent_name].present?
    end
  end

  describe "#overlaps_rdv_or_absence?" do
    let(:motif2) { create(:motif, name: "Visite 12 mois", default_duration_in_min: 60, online: online) }
    let(:creneau) { Creneau.new(starts_at: Time.zone.local(2019, 9, 19, 9, 0), lieu_id: lieu.id, motif: motif2) }

    describe "for absences" do
      subject { creneau.overlaps_rdv_or_absence?([absence]) }

      describe "absence overlaps beginning of creneau" do
        let!(:absence) { create(:absence, starts_at: Time.zone.local(2019, 9, 19, 8, 30), ends_at: Time.zone.local(2019, 9, 19, 9, 30), agent: agent) }
        it { is_expected.to eq(true) }
      end

      describe "absence overlaps end of creneau" do
        let!(:absence) { create(:absence, starts_at: Time.zone.local(2019, 9, 19, 9, 30), ends_at: Time.zone.local(2019, 9, 19, 10, 30), agent: agent) }
        it { is_expected.to eq(true) }
      end

      describe "absence is inside creneau" do
        let!(:absence) { create(:absence, starts_at: Time.zone.local(2019, 9, 19, 9, 15), ends_at: Time.zone.local(2019, 9, 19, 9, 30), agent: agent) }
        it { is_expected.to eq(true) }
      end

      describe "absence is before creneau" do
        let!(:absence) { create(:absence, starts_at: Time.zone.local(2019, 9, 19, 8, 0), ends_at: Time.zone.local(2019, 9, 19, 9, 0o0), agent: agent) }
        it { is_expected.to eq(false) }
      end

      describe "absence is after creneau" do
        let!(:absence) { create(:absence, starts_at: Time.zone.local(2019, 9, 19, 10, 0o0), ends_at: Time.zone.local(2019, 9, 19, 10, 30), agent: agent) }
        it { is_expected.to eq(false) }
      end

      describe "absence is around creneau" do
        let!(:absence) { create(:absence, starts_at: Time.zone.local(2019, 9, 19, 8, 0o0), ends_at: Time.zone.local(2019, 9, 19, 10, 30), agent: agent) }
        it { is_expected.to eq(true) }
      end

      describe "absence is like creneau" do
        let!(:absence) { create(:absence, starts_at: Time.zone.local(2019, 9, 19, 9, 0o0), ends_at: Time.zone.local(2019, 9, 19, 10, 0o0), agent: agent) }
        it { is_expected.to eq(true) }
      end
    end

    describe "for rdvs" do
      subject { creneau.overlaps_rdv_or_absence?([rdv]) }

      describe "rdv overlaps beginning of creneau" do
        let(:rdv) { build(:rdv, starts_at: Time.zone.local(2019, 9, 19, 8, 30), duration_in_min: 45, agents: [agent]) }
        it { is_expected.to eq(true) }
      end

      describe "rdv overlaps end of creneau" do
        let(:rdv) { build(:rdv, starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 45, agents: [agent]) }
        it { is_expected.to eq(true) }
      end

      describe "rdv is inside creneau" do
        let(:rdv) { build(:rdv, starts_at: Time.zone.local(2019, 9, 19, 9, 15), duration_in_min: 30, agents: [agent]) }
        it { is_expected.to eq(true) }
      end

      describe "rdv is before creneau" do
        let(:rdv) { build(:rdv, starts_at: Time.zone.local(2019, 9, 19, 8, 0), duration_in_min: 60, agents: [agent]) }
        it { is_expected.to eq(false) }
      end

      describe "rdv is after creneau" do
        let(:rdv) { build(:rdv, starts_at: Time.zone.local(2019, 9, 19, 10, 0o0), duration_in_min: 45, agents: [agent]) }
        it { is_expected.to eq(false) }
      end

      describe "rdv is around creneau" do
        let(:rdv) { build(:rdv, starts_at: Time.zone.local(2019, 9, 19, 8, 0o0), duration_in_min: 140, agents: [agent]) }
        it { is_expected.to eq(true) }
      end

      describe "rdv is like creneau" do
        let(:rdv) { build(:rdv, starts_at: Time.zone.local(2019, 9, 19, 9, 0o0), duration_in_min: 60, agents: [agent]) }
        it { is_expected.to eq(true) }
      end
    end
  end

  describe "#available_plages_ouverture" do
    let(:creneau) { Creneau.new(starts_at: Time.zone.local(2019, 9, 19, 9, 0), lieu_id: lieu.id, motif: motif) }

    subject { creneau.available_plages_ouverture }

    it { expect(subject).to contain_exactly(plage_ouverture) }

    describe "with an other plage_ouverture for this motif" do
      let!(:plage_ouverture2) { create(:plage_ouverture, motifs: [motif], lieu: lieu, first_day: today, start_time: Tod::TimeOfDay.new(9), end_time: Tod::TimeOfDay.new(11)) }

      it { expect(subject).to contain_exactly(plage_ouverture, plage_ouverture2) }
    end

    describe "with an other plage_ouverture with another motif" do
      let(:motif2) { create(:motif, name: "Visite 12 mois", default_duration_in_min: 60, online: online) }
      let!(:plage_ouverture3) { create(:plage_ouverture, title: "Permanence visite 12 mois", motifs: [motif2], lieu: lieu, first_day: today, start_time: Tod::TimeOfDay.new(9), end_time: Tod::TimeOfDay.new(11)) }

      it { expect(subject).to contain_exactly(plage_ouverture) }
    end

    describe "with an other plage_ouverture but not opened the right time" do
      let!(:plage_ouverture4) { create(:plage_ouverture, motifs: [motif], lieu: lieu, first_day: today, start_time: Tod::TimeOfDay.new(14), end_time: Tod::TimeOfDay.new(18)) }

      it { expect(subject).to contain_exactly(plage_ouverture) }
    end
  end
end
