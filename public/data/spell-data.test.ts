import { describe, it, expect, beforeEach } from 'vitest';
import {
  SPELLS,
  TALENTS,
  SUMMARY,
  getSpellId,
  getTalentId,
  getTalentInfo,
  spellExists,
  talentExists,
  findSpells,
  findTalents,
  talentsForSpec
} from './spell-data';

describe('spell-data', () => {
  describe('getSpellId', () => {
    it('returns spell ID for known spells', () => {
      // Use a known spell from the data
      const spellName = Object.keys(SPELLS)[0];
      const expectedId = SPELLS[spellName];
      expect(getSpellId(spellName)).toBe(expectedId);
    });

    it('throws error for unknown spell', () => {
      expect(() => getSpellId('NonexistentSpell')).toThrow('Unknown spell: NonexistentSpell');
    });
  });

  describe('getTalentId', () => {
    it('returns talent ID for known talents', () => {
      const talentName = Object.keys(TALENTS)[0];
      if (talentName) {
        const expectedId = TALENTS[talentName].id;
        expect(getTalentId(talentName)).toBe(expectedId);
      }
    });

    it('throws error for unknown talent', () => {
      expect(() => getTalentId('NonexistentTalent')).toThrow('Unknown talent: NonexistentTalent');
    });
  });

  describe('getTalentInfo', () => {
    it('returns talent info for known talents', () => {
      const talentName = Object.keys(TALENTS)[0];
      if (talentName) {
        const expectedInfo = TALENTS[talentName];
        expect(getTalentInfo(talentName)).toEqual(expectedInfo);
      }
    });

    it('throws error for unknown talent', () => {
      expect(() => getTalentInfo('NonexistentTalent')).toThrow('Unknown talent: NonexistentTalent');
    });
  });

  describe('spellExists', () => {
    it('returns true for existing spells', () => {
      const spellName = Object.keys(SPELLS)[0];
      expect(spellExists(spellName)).toBe(true);
    });

    it('returns false for non-existing spells', () => {
      expect(spellExists('NonexistentSpell')).toBe(false);
    });
  });

  describe('talentExists', () => {
    it('returns true for existing talents', () => {
      const talentName = Object.keys(TALENTS)[0];
      if (talentName) {
        expect(talentExists(talentName)).toBe(true);
      }
    });

    it('returns false for non-existing talents', () => {
      expect(talentExists('NonexistentTalent')).toBe(false);
    });
  });

  describe('findSpells', () => {
    it('finds spells by partial name', () => {
      const spellNames = Object.keys(SPELLS);
      if (spellNames.length > 0) {
        const firstSpell = spellNames[0];
        const partialName = firstSpell.substring(0, 3);
        const results = findSpells(partialName);
        
        expect(Object.keys(results).length).toBeGreaterThan(0);
        expect(results[firstSpell]).toBe(SPELLS[firstSpell]);
      }
    });

    it('returns empty object for non-matching partial name', () => {
      const results = findSpells('XYZ123NonExistent');
      expect(results).toEqual({});
    });
  });

  describe('findTalents', () => {
    it('finds talents by partial name', () => {
      const talentNames = Object.keys(TALENTS);
      if (talentNames.length > 0) {
        const firstTalent = talentNames[0];
        const partialName = firstTalent.substring(0, 3);
        const results = findTalents(partialName);
        
        expect(Object.keys(results).length).toBeGreaterThan(0);
        expect(results[firstTalent]).toEqual(TALENTS[firstTalent]);
      }
    });

    it('returns empty object for non-matching partial name', () => {
      const results = findTalents('XYZ123NonExistent');
      expect(results).toEqual({});
    });
  });

  describe('talentsForSpec', () => {
    it('finds talents for specific spec', () => {
      const talentValues = Object.values(TALENTS);
      if (talentValues.length > 0) {
        const specName = talentValues[0].spec;
        const results = talentsForSpec(specName);
        
        expect(Object.keys(results).length).toBeGreaterThan(0);
        Object.values(results).forEach(talent => {
          expect(talent.spec.toLowerCase()).toContain(specName.toLowerCase());
        });
      }
    });

    it('returns empty object for non-existing spec', () => {
      const results = talentsForSpec('NonExistentSpec');
      expect(results).toEqual({});
    });
  });

  describe('data exports', () => {
    it('exports SPELLS as Record<string, number>', () => {
      expect(typeof SPELLS).toBe('object');
      const spellEntries = Object.entries(SPELLS);
      if (spellEntries.length > 0) {
        const [name, id] = spellEntries[0];
        expect(typeof name).toBe('string');
        expect(typeof id).toBe('number');
      }
    });

    it('exports TALENTS as Record<string, TalentInfo>', () => {
      expect(typeof TALENTS).toBe('object');
      const talentEntries = Object.entries(TALENTS);
      if (talentEntries.length > 0) {
        const [name, info] = talentEntries[0];
        expect(typeof name).toBe('string');
        expect(typeof info.id).toBe('number');
        expect(typeof info.spec).toBe('string');
      }
    });

    it('exports SUMMARY with required fields', () => {
      expect(typeof SUMMARY).toBe('object');
      expect(typeof SUMMARY.total_spells).toBe('number');
      expect(typeof SUMMARY.total_talents).toBe('number');
      expect(Array.isArray(SUMMARY.classes)).toBe(true);
      expect(Array.isArray(SUMMARY.sample_spells)).toBe(true);
      expect(Array.isArray(SUMMARY.sample_talents)).toBe(true);
      expect(typeof SUMMARY.generated_at).toBe('string');
    });
  });
});