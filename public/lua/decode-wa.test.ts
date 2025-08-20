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
  const mockProcess = {
    stdin: {
      setEncoding: vi.fn(),
      on: vi.fn()
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
    expect(mockProcess.stdin.on).toHaveBeenCalledWith('data', expect.any(Function));
  });

  it('reads required lua files', async () => {
    await import('./decode-wa');
    
    const { LuaFactory } = await import('wasmoon');
    const mockFactory = new LuaFactory();
    
    // Trigger the data event
    const dataHandler = vi.mocked(mockProcess.stdin.on).mock.calls[0][1];
    await dataHandler('test input');

    expect(mockFactory.mountFile).toHaveBeenCalledTimes(5);
    expect(mockFactory.mountFile).toHaveBeenCalledWith('LibDeflate.lua', 'mock lua content');
    expect(mockFactory.mountFile).toHaveBeenCalledWith('LibSerialize.lua', 'mock lua content');
    expect(mockFactory.mountFile).toHaveBeenCalledWith('dkjson.lua', 'mock lua content');
    expect(mockFactory.mountFile).toHaveBeenCalledWith('inspect.lua', 'mock lua content');
    expect(mockFactory.mountFile).toHaveBeenCalledWith('encode.lua', 'mock lua content');
  });

  it('handles valid JSON output', async () => {
    await import('./decode-wa');
    
    const { LuaFactory } = await import('wasmoon');
    const mockFactory = new LuaFactory();
    const mockEngine = await mockFactory.createEngine();
    const mockDecode = vi.fn().mockReturnValue('{"test": "value"}');
    
    vi.mocked(mockEngine.global.get).mockReturnValue(mockDecode);
    
    const consoleSpy = vi.spyOn(console, 'log').mockImplementation();
    
    // Trigger the data event
    const dataHandler = vi.mocked(mockProcess.stdin.on).mock.calls[0][1];
    await dataHandler('test input');

    expect(mockDecode).toHaveBeenCalledWith('test input');
    expect(consoleSpy).toHaveBeenCalledWith('{\n  "test": "value"\n}');
    expect(mockEngine.global.close).toHaveBeenCalled();
    expect(mockProcess.exit).toHaveBeenCalled();
    
    consoleSpy.mockRestore();
  });

  it('handles invalid JSON output', async () => {
    await import('./decode-wa');
    
    const { LuaFactory } = await import('wasmoon');
    const mockFactory = new LuaFactory();
    const mockEngine = await mockFactory.createEngine();
    const mockDecode = vi.fn().mockReturnValue('invalid json');
    
    vi.mocked(mockEngine.global.get).mockReturnValue(mockDecode);
    
    const consoleSpy = vi.spyOn(console, 'log').mockImplementation();
    
    // Trigger the data event
    const dataHandler = vi.mocked(mockProcess.stdin.on).mock.calls[0][1];
    await dataHandler('test input');

    expect(mockDecode).toHaveBeenCalledWith('test input');
    expect(consoleSpy).toHaveBeenCalledWith('invalid json');
    expect(mockEngine.global.close).toHaveBeenCalled();
    expect(mockProcess.exit).toHaveBeenCalled();
    
    consoleSpy.mockRestore();
  });

  it('trims input before processing', async () => {
    await import('./decode-wa');
    
    const { LuaFactory } = await import('wasmoon');
    const mockFactory = new LuaFactory();
    const mockEngine = await mockFactory.createEngine();
    const mockDecode = vi.fn().mockReturnValue('{}');
    
    vi.mocked(mockEngine.global.get).mockReturnValue(mockDecode);
    vi.spyOn(console, 'log').mockImplementation();
    
    // Trigger the data event with whitespace
    const dataHandler = vi.mocked(mockProcess.stdin.on).mock.calls[0][1];
    await dataHandler('  test input  \n');

    expect(mockDecode).toHaveBeenCalledWith('test input');
  });
});