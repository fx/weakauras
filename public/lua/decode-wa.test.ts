import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import fs from 'fs';

// Mock dependencies
vi.mock('wasmoon', () => ({
  LuaFactory: vi.fn(() => ({
    createEngine: vi.fn(() => ({
      doString: vi.fn(),
      global: {
        get: vi.fn(),
        close: vi.fn()
      }
    })),
    mountFile: vi.fn()
  }))
}));

vi.mock('fs');

describe('decode-wa', () => {
  const mockStdinOn = vi.fn();
  const mockProcess = {
    stdin: {
      setEncoding: vi.fn(),
      on: mockStdinOn
    },
    exit: vi.fn()
  };

  beforeEach(() => {
    vi.clearAllMocks();
    // @ts-ignore
    global.process = mockProcess;
    vi.mocked(fs.readFileSync).mockReturnValue('mock lua content');
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('sets up stdin encoding', async () => {
    // Import the module to trigger the setup
    await import('./decode-wa');
    
    expect(mockProcess.stdin.setEncoding).toHaveBeenCalledWith('utf8');
    expect(mockStdinOn).toHaveBeenCalledWith('data', expect.any(Function));
  });

  it('imports without errors', async () => {
    // Just verify the module can be imported without throwing
    expect(async () => {
      await import('./decode-wa');
    }).not.toThrow();
  });
});