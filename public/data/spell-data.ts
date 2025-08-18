// Auto-generated from SimC data - loads from JSON files
// Run: ruby scripts/parse_simc_data.rb to regenerate source data

import spellsData from './spells.json';
import talentsData from './talents.json';
import summaryData from './summary.json';

export interface TalentInfo {
  id: number;
  spec: string;
  tree: string;
  row: number;
  col: number;
  max_rank: number;
  req_points: number;
}

export interface Summary {
  total_spells: number;
  total_talents: number;
  classes: string[];
  sample_spells: string[];
  sample_talents: string[];
  generated_at: string;
}

// Type-safe access to spell and talent data
export const SPELLS: Record<string, number> = spellsData as Record<string, number>;
export const TALENTS: Record<string, TalentInfo> = talentsData as Record<string, TalentInfo>;
export const SUMMARY: Summary = summaryData as Summary;

export function getSpellId(name: string): number {
  const id = SPELLS[name];
  if (id === undefined) {
    throw new Error(`Unknown spell: ${name}`);
  }
  return id;
}

export function getTalentId(name: string): number {
  const talent = TALENTS[name];
  if (!talent) {
    throw new Error(`Unknown talent: ${name}`);
  }
  return talent.id;
}

export function getTalentInfo(name: string): TalentInfo {
  const talent = TALENTS[name];
  if (!talent) {
    throw new Error(`Unknown talent: ${name}`);
  }
  return talent;
}

export function spellExists(name: string): boolean {
  return name in SPELLS;
}

export function talentExists(name: string): boolean {
  return name in TALENTS;
}

// Search functions
export function findSpells(partialName: string): Record<string, number> {
  const pattern = new RegExp(partialName, 'i');
  const results: Record<string, number> = {};
  
  for (const [name, id] of Object.entries(SPELLS)) {
    if (pattern.test(name)) {
      results[name] = id;
    }
  }
  
  return results;
}

export function findTalents(partialName: string): Record<string, TalentInfo> {
  const pattern = new RegExp(partialName, 'i');
  const results: Record<string, TalentInfo> = {};
  
  for (const [name, data] of Object.entries(TALENTS)) {
    if (pattern.test(name)) {
      results[name] = data;
    }
  }
  
  return results;
}

export function talentsForSpec(specName: string): Record<string, TalentInfo> {
  const pattern = new RegExp(specName, 'i');
  const results: Record<string, TalentInfo> = {};
  
  for (const [name, data] of Object.entries(TALENTS)) {
    if (pattern.test(data.spec)) {
      results[name] = data;
    }
  }
  
  return results;
}